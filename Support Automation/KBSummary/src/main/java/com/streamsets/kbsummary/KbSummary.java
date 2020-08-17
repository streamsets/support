package com.streamsets.kbsummary;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.zendesk.client.v2.model.Comment;
import org.zendesk.client.v2.model.Ticket;

import javax.xml.bind.DatatypeConverter;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class KbSummary {
  private static final Logger LOG = LoggerFactory.getLogger(KbSummary.class);
  private static final SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd");

  private static final String ZENDESK_EMAIL = "zendesk_email";
  private static final String ZENDESK_TOKEN = "zendesk_token";
  private static final String SUPPORT_DW_USERNAME = "support_dw_username";
  private static final String SUPPORT_DW_PASSWORD = "support_dw_password";
  private static final String SUPPORT_DW_CONNECTION_STRING = "support_dw_connection_string";

  private static Date start;
  private static Date end;

  private KbSummary() {

  }

  public static void main(String[] args) {
    String startDate = "";
    String endDate = "";
    String updateString = "";
    boolean update;

    Options options = new Options();

    Option st = new Option("s", "start", true, "start date (oldest) yyyy/MM/dd");
    st.setRequired(true);
    options.addOption(st);

    Option en = new Option("e", "end", true, "end date (recent) yyyy/MM/dd");
    en.setRequired(true);
    options.addOption(en);

    Option up = new Option("u", "update", true, "update database true/false");
    up.setRequired(true);
    options.addOption(up);

    CommandLineParser parser = new DefaultParser();
    HelpFormatter formatter = new HelpFormatter();
    CommandLine cmd;

    try {
      cmd = parser.parse(options, args);
      startDate = cmd.getOptionValue("start");
      endDate = cmd.getOptionValue("end");
      updateString = cmd.getOptionValue("update");
    } catch (org.apache.commons.cli.ParseException e) {
      System.out.println(e.getMessage());
      LOG.error(e.getMessage());
      formatter.printHelp("KbSummary", options);
      System.exit(1);
    }

    try {
      start = sdf.parse(startDate);
    } catch (java.text.ParseException ex) {
      LOG.error("start date parse error - should be yyyy/MM/dd, not {}", startDate);
      System.exit(1);
    }

    try {
      end = sdf.parse(endDate);
    } catch (java.text.ParseException ex) {
      LOG.error("end date parse error - should be yyyy/MM/dd, not {}", endDate);
      System.exit(1);
    }

    update = updateString.equalsIgnoreCase("true");

    final long start = System.currentTimeMillis();
    KbSummary kbs = new KbSummary();

    AWSSecret aws = new AWSSecret();
    Map<String, String> credentials = aws.getSecret(System.getenv("SECRET_NAME"), System.getenv("AWS_REGION"));

    try (MyZendeskAPI zdAPI = new MyZendeskAPI(credentials.get(ZENDESK_EMAIL), credentials.get(ZENDESK_TOKEN))) {
      kbs.run(credentials, update, zdAPI);
    }

    final long elapsed = (System.currentTimeMillis() - start) / 1000L;
    LOG.info("elapsed time " + elapsed);
  }

  private void run(Map<String, String> credentials, boolean update, MyZendeskAPI zdAPI) {
    LOG.info("start '{}'", start);
    LOG.info("end '{}'", end);
    LOG.info("update '{}'", update);

    int ticketCount = 0;
    int commentCount = 0;
    int kbCount = 0;

    final long INTERVAL = 10L * 86400L * 1000L;   // 30 days * 86400 seconds in a day * 1000 for millis.
    long endEpoch = end.getTime();
    long theEnd = end.getTime() - INTERVAL;
    if (theEnd < start.getTime()) {
      theEnd = start.getTime();
    }

    do {
      Iterable<Ticket> tickets = zdAPI.getTickets(new Date(theEnd), new Date(endEpoch));
      for (Ticket t : tickets) {
        ++ticketCount;
        if (ticketCount % 100 == 0) {
          LOG.info("ticketCount: {}  comments checked: {}", ticketCount, commentCount);
        }
        Iterable<Comment> comments = zdAPI.getComments(t.getId());
        Set<KBInfo> kbinfo = new HashSet<>();
        for (Comment c : comments) {

          // TODO: maybe not hard code this.
          // If this comment was created by the "Streamsets Support" user, we should skip it.
          // StreamSets Support user number ==  411020321314L
          if (c.getAuthorId() == 411020321314L) {
            continue;
          }

          ++commentCount;
          final String SEARCH_TEXT = "https://support.streamsets.com/hc/en-us/articles";
          if (c.getBody().contains(SEARCH_TEXT)) {
            ++kbCount;
            String theText = c.getBody().replaceAll("[\n\r\t]", " ");
            int ix = theText.indexOf(SEARCH_TEXT);
            theText = theText.substring(ix);
            int end = theText.indexOf(" ");
            if (end > 0) {
              theText = theText.substring(0, end);
            }

            // calculate MD5 hash.
            try {
              byte[] bytes = theText.getBytes(StandardCharsets.UTF_8);

              MessageDigest md = MessageDigest.getInstance("MD5");
              byte[] digest = md.digest(bytes);
              String d = DatatypeConverter.printHexBinary(digest);
              kbinfo.add(new KBInfo(t.getId(), theText, d, c.getCreatedAt()));

            } catch (NoSuchAlgorithmException ex) {
              System.out.println("exception " + ex.getMessage() + " ticket: " + t.getId() + " kb: " + theText);
              ex.printStackTrace();
              System.exit(1);
            }
          }
        }

        if (update && kbinfo.size() > 0) {
          try (Database db = new Database(credentials.get(SUPPORT_DW_CONNECTION_STRING),
              credentials.get(SUPPORT_DW_USERNAME),
              credentials.get(SUPPORT_DW_PASSWORD)
          )) {
            for (KBInfo k : kbinfo) {
              db.insertKB(k.getTicketNum(), k.getLink(), k.getHash(), k.getCommentDate());
            }
          }
        } else {
          for (KBInfo k : kbinfo) {
            LOG.info("did not update DB for {} {} {} {}",
                k.getTicketNum(),
                k.getCommentDate(),
                k.getHash(),
                k.getLink()
            );
          }
        }
      }  // for all tickets in time range.

      endEpoch -= INTERVAL;
      if (endEpoch < start.getTime()) {
        break;
      }
      theEnd -= INTERVAL;
      if (theEnd < start.getTime()) {
        theEnd = start.getTime();
      }
      //TODO: remove debugging code.
      //      System.out.println("end " + endEpoch + "   " + new Date(endEpoch) + "   " + theEnd + "    start  " +
      //      new Date(
      //          theEnd));
    } while (theEnd > start.getTime());

    LOG.info("tickets: {} comments: {} kbs: {}", ticketCount, commentCount, kbCount);
  }
}
