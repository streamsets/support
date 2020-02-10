package com.streamsets.deletecases;

import org.apache.commons.lang3.StringUtils;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class DeleteCases {

  private DeleteCases() throws IOException {
  }

  public static void main(String... args) throws IOException {

    if (StringUtils.isEmpty(System.getenv("ZENDESK_EMAIL"))) {
      System.out.println(
          "Please set the ZENDESK_EMAIL environment variable: `export ZENDESK_EMAIL=\"you@streamsets.com\"`");
      System.exit(5);
    }

    if (StringUtils.isEmpty(System.getenv("ZENDESK_TOKEN"))) {
      System.out.println(
          "Please set the ZENDESK_TOKEN environment variable: `export ZENDESK_TOKEN=\"c09284827blahblahblahg1h14g5\"`");
      System.exit(5);
    }

    // gather Zendesk info:
    ZendeskCases zd = new ZendeskCases(System.getenv("ZENDESK_EMAIL"), System.getenv("ZENDESK_TOKEN"));
    Map<Long, String> zdinfo = zd.getCaseStatus();
    zd.close();

    DeleteCases dc = new DeleteCases();
    dc.process(zdinfo);
  }

  private void process(Map<Long, String> zdinfo) throws IOException {
    Map<String, Long> cases = new HashMap<>();

    // gather all directories in the  current directory
    File[] files = new File("/Users/bob/Downloads").listFiles(File::isDirectory);

    for (File file : files) {
      String[] parts = file.getName().split("_");
      if (parts.length != 4) {
        continue;
      }

      long caseNumber;
      try {
        caseNumber = Long.parseLong(parts[1]);
      } catch (NumberFormatException ex) {
        System.out.println("NumberFormatException  on '" + file.getName() + " " + ex.getMessage());
        continue;
      }

      // check ZD status here.
      if (zdinfo.get(caseNumber) != null) {
        // add it to the map.
        cases.put(file.getCanonicalPath(), caseNumber);
      }

    }
    for (Map.Entry<String, Long> ent : cases.entrySet()) {
      System.out.println("rm -rf " + ent.getKey());
    }
    System.out.println("size " + cases.size());
  }
}