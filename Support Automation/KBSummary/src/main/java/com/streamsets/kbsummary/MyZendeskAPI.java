package com.streamsets.kbsummary;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.zendesk.client.v2.Zendesk;
import org.zendesk.client.v2.model.Comment;
import org.zendesk.client.v2.model.Ticket;
import org.zendesk.client.v2.model.User;
import org.zendesk.client.v2.model.hc.Article;

import java.text.SimpleDateFormat;
import java.util.Date;

public class MyZendeskAPI implements AutoCloseable {
  private static final Logger LOG = LoggerFactory.getLogger(MyZendeskAPI.class);

  Zendesk zd;

  MyZendeskAPI(String email, String token) {
    zd = new Zendesk.Builder("https://streamsets.zendesk.com").setUsername(email)
        .setToken(token)
        .setRetry(false)
        .build();
    if (zd == null) {
      LOG.error("cannot create ZendeskAPI.");
      System.exit(10);
    }
  }

  Iterable<Ticket> getTickets(Date start, Date end) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String query = String.format("group:\"Support\" solved>=%s solved<=%s", sdf.format(start), sdf.format(end));
    return zd.getTicketsFromSearch(query);
  }

  Iterable<Comment> getComments(long ticketId) {
    return zd.getRequestComments(ticketId);
  }

  Iterable<Article> getArticles() {
    String search = "";

    return zd.getArticleFromSearch(search);
  }

  User getUser(long id) {
    return zd.getUser(id);
  }

  public void close() {
    zd.close();
  }
}
