package com.streamsets.downloadsendsafely;

import com.sendsafely.SendSafely;

import java.io.File;
import java.util.Scanner;

import static org.apache.commons.io.FileUtils.moveFile;

public class DownloadSendSafely {

  public static void main(String[] args) throws Exception {

    final String KEY = "SENDSAFELY_API_KEY";
    final String SECRET = "SENDSAFELY_API_SECRET";

    // fetch API_KEY and API_SECRET from the environment
    final String apiKey = System.getenv(KEY);
    final String apiSecret = System.getenv(SECRET);
    if(apiKey.isEmpty()) {
      System.out.println("Could not access environment variable: " + KEY);
      System.exit(27);
    }

    if(apiSecret.isEmpty()) {
      System.out.println("Could not access environment variable: " + SECRET);
      System.exit(27);
    }

    System.out.println("Enter package link to download: ");
    Scanner sc = new Scanner(System.in);
    final String packageLink = sc.nextLine();
    if(packageLink.isEmpty()) {
      System.out.println("Package link seems to be empty.");
      System.exit(27);
    }

    SendSafely sendsafely = new SendSafely("https://app.sendsafely.com", apiKey, apiSecret);
    com.sendsafely.Package pkg = sendsafely.getPackageInformationFromLink(packageLink);
    for (com.sendsafely.File file : pkg.getFiles()) {
      File newFile = sendsafely.downloadFile(pkg.getPackageId(),
          file.getFileId(),
          pkg.getKeyCode(),
          new ProgressCallback()
      );
      File dest = new File("./" + file.getFileName());
      moveFile(newFile, dest);
      System.out.println("Downloaded File: " + dest.getName() + " Length: " + dest.length());
    }
  }
}
