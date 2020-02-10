package com.streamsets.deletecases;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.zendesk.client.v2.Zendesk;
import org.zendesk.client.v2.model.Comment;
import org.zendesk.client.v2.model.Ticket;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.function.DoubleToIntFunction;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class ZendeskCases {

  private Zendesk zd;
  private Pattern pattern = Pattern.compile("[ \\n\\r\\f\\t]");

  ZendeskCases(String zendeskUsername, String zendeskToken) {
    zd = new Zendesk.Builder("https://streamsets.zendesk.com")
        .setUsername(zendeskUsername)
        .setToken(zendeskToken)
        .build();
  }

  Map<Long, String> getCaseStatus() {
    Map<Long, String> caseStatus = new HashMap<>();

    for (Ticket ticket : zd.getTickets()) {
      // check all the tickets - only save SOLVED.
      if (ticket.getStatus().toString().equalsIgnoreCase("solved") || ticket.getStatus().toString().equalsIgnoreCase("closed") ){
        caseStatus.put(ticket.getId(), "solved");
      }
    }

    System.out.println("num zd cases " + caseStatus.size());
    return caseStatus;
  }

  void close() {
    zd.close();
  }
}

