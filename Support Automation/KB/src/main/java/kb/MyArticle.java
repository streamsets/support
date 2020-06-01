package kb;

import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.WordUtils;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.StringJoiner;
import java.util.TimeZone;

public class MyArticle {
  private long id;

  private String title = "";
  private String body = "";
  private String version = "";
  private List<String> keywords = new ArrayList<>();

  MyArticle(long id, String title) {
    this.id = id;
    this.title = title;
  }

  String getTitle() {
    return this.title;
  }

  void setTitle(String title) {
    this.title = title;
  }

  Long getId() {
    return this.id;
  }

  String getBody() {
    return this.body;
  }

  void setBody(String body) {
    // want to strip out the crap here.
    body = body.replace("**ISSUE:", "ISSUE:");
    body = body.replace("**RESOLUTION:", "RESOLUTION:");

    // last - replace "**" - it indicates bold.
    body = body.replace("**", "");
    this.body = body;
  }

  String getVersion() {
    return this.version;
  }

  void setVersion(String version) {
    this.version = version;
  }

  void addKeyword(String word) {
    this.keywords.add(word);
  }

  List<String> getKeywords() {
    return this.keywords;
  }

  void setKeywords(List<String> keywords) {
    this.keywords = keywords;
  }

 void addFooter() {
  // append the keywords to the bottom of the body.
  StringJoiner sj = new StringJoiner(", ", "Keywords: ", "");
    if (keywords.size() > 0) {
    for (String s : keywords) {
      sj.add(s);
    }
  }
  body += "\n\n------\n" + sj.toString() + "\n";

  // append the version to the bottom of the body.
    if (!StringUtils.isEmpty(version)) {
    body += version+ "\n";
  }

  // appends a date stamp and ZD ticket.
  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss Z");
    sdf.setTimeZone(TimeZone.getTimeZone("UTC"));
  body += "Created: " + sdf.format(new Date()) + "  Xref: " + id  + "\n";
}

}
