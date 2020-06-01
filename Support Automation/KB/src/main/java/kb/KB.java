package kb;

import org.apache.commons.lang3.StringUtils;
import org.zendesk.client.v2.model.hc.Section;

import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class KB {
  private static final String ZENDESK_EMAIL = "ZENDESK_EMAIL";
  private static final String ZENDESK_TOKEN = "ZENDESK_TOKEN";

  public static void main(String... args) {

    String zendeskEmail = System.getenv(ZENDESK_EMAIL);
    String zendeskToken = System.getenv(ZENDESK_TOKEN);

    if (StringUtils.isEmpty(zendeskEmail) || StringUtils.isEmpty(zendeskToken)) {
      System.out.println(ZENDESK_EMAIL + " or " + ZENDESK_TOKEN + " is empty");
      System.exit(2);
    }

    // gather the ZD number:
    System.out.print("Enter ZD ticket number (eg: 11439, 11076)  => ");
    Scanner sc = new Scanner(System.in);
    long num = sc.nextLong();

    AccessZendesk zd = new AccessZendesk(zendeskEmail, zendeskToken);
    MyArticle myArticle = zd.getMyArticle(num);  //get ZD ticket - start to create article

    System.out.println("title: " + myArticle.getTitle());
    System.out.println("body: " + myArticle.getBody());
    System.out.println("keywords: " + myArticle.getKeywords());
    System.out.println("version: " + myArticle.getVersion());

    if (StringUtils.isEmpty(myArticle.getTitle()) || StringUtils.isEmpty(myArticle.getBody())) {
      System.out.println("ZD ticket " + num + " does not have a title or a body.");
      System.exit(27);
    }

    // should this be set to Knowledgebase?
    System.out.print("\n\nUpload as a Knowledge Base article? (y/N) => ");
    String ans = sc.next();
    if (ans.toUpperCase().contains("N")) {
      zd.close();
      System.exit(0);
    }

    // get the scrtions:
    Iterable<Section> sections = zd.getSections();
    List<Section> list = new ArrayList<>();
    long count = 1;
    for (Section s : sections) {
      System.out.println(count + ") " + s.getName());
      list.add(s);
      count++;
    }
    System.out.print("Select KnowledgeBase Section => ");

    int choice = sc.nextInt();

    zd.postToKB(myArticle, list.get(choice - 1));
    zd.close();
  }

}
