package kb;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.WordUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.zendesk.client.v2.Zendesk;
import org.zendesk.client.v2.model.Comment;
import org.zendesk.client.v2.model.CustomFieldValue;
import org.zendesk.client.v2.model.Ticket;
import org.zendesk.client.v2.model.hc.Article;
import org.zendesk.client.v2.model.hc.PermissionGroup;
import org.zendesk.client.v2.model.hc.Section;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

class AccessZendesk {
  private static final Logger LOG = LoggerFactory.getLogger(AccessZendesk.class);
  Map<Long, String> customerXref = new HashMap<>();
  private Zendesk zd;
  private Pattern pattern = Pattern.compile("[ \\n\\r\\f\\t]");

  AccessZendesk(String zendeskEmail, String zendeskToken) {
    zd = new Zendesk.Builder("https://streamsets.zendesk.com").setUsername(zendeskEmail).setToken(zendeskToken).build();
  }

  MyArticle getMyArticle(long id) {
    final String SUMMARY = "Summary of the ticket:";
    final String THE_END = "Thanks";

    Ticket ticket = zd.getTicket(id);

    MyArticle myArticle = new MyArticle(id, ticket.getSubject());

    // gather the keywords from the "customFields"
    for (CustomFieldValue f : ticket.getCustomFields()) {
      // this magic number is the "Components" field.
      if (f.getId() == 360009237153L && f.getValue() != null) {
        for (String s : f.getValue()) {
          myArticle.addKeyword(cleanUp(s));
        }
        // this magic number is the custom field id for the product version.
      } else if (f.getId() == 80670167L && f.getValue() != null) {
        for (String s : f.getValue()) {
          myArticle.setVersion(cleanUp(s));  // yes, ovewritting if there are multiple.
        }
      }
    }
    // gather all the comments for a ticket.
    Iterable<Comment> comments = zd.getTicketComments(id);
    for (Comment c : comments) {
      // is this comment the SUMMARY of the issue?
      int start = c.getBody().indexOf(SUMMARY);
      if (start < 0) {
        //nope.
        continue;
      }

      // find the end of the summary:
      int end = c.getBody().indexOf(THE_END);

      // add the length of the SUMMARY text:
      if (end < 0) {
        myArticle.setBody(c.getBody().substring(start + SUMMARY.length()));
      } else {
        // if we found THE_END:
        myArticle.setBody(c.getBody().substring(start + SUMMARY.length(), end));
      }

      myArticle.addFooter();
      myArticle.setBody(cleanUp(myArticle.getBody()));
      break;
    }
    return myArticle;
  }

  void close() {
    zd.close();
  }


  void postToKB(MyArticle my, Section section){
    Article a = new Article();
    a.setTitle(my.getTitle());
    a.setBody(my.getBody());
    a.setAuthorId(zd.getAuthenticatedUser().getId());
    a.setLocale("en-us");
    a.setDraft(true);
    a.setSectionId(section.getId());
    a.setPermissionGroupId(247408L);  // maybe should not hard-code this
    a.setUserSegmentId(2438067L);     // maybe should not hard-code this.
    a.setLabelNames(my.getKeywords());
    Article na = zd.createArticle(a, false);
  }

  String cleanUp(String input) {

    input = input.replace("_", " ");
    input = WordUtils.capitalize(input);
    input = input.replaceAll(" O$", " Origin");
    input = input.replaceAll(" D$", " Destination");
    input = input.replaceAll(" P$", " Processor");
    input = input.replace(" - ", "-");
    input = input.replace("Sdc", "SDC");
    input = input.replace("SCH", "SCH");
    input = input.replace("\n", "<br></br>");
    return input;
  }

  Iterable<Section> getSections() {
    return zd.getSections();
  }

  Iterable<PermissionGroup> getPermissions() {
    return zd.getPermissionGroups();
  }
}
