package com.streamsets.kbsummary;

import java.util.Date;

public class KBInfo {

  private final long ticketNum;
  private final String link;
  private final String hash;
  private final Date commentDate;

  KBInfo(long ticketNum, String link, String hash, Date commentDate) {
    this.ticketNum = ticketNum;
    this.link = link;
    this.hash = hash;
    this.commentDate = commentDate;
  }

  public long getTicketNum() {
    return ticketNum;
  }

  public String getLink() {
    return link;
  }

  public String getHash() {
    return hash;
  }

  public Date getCommentDate() {
    return commentDate;
  }


}
