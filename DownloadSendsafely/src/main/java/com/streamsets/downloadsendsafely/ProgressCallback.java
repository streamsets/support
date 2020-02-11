package com.streamsets.downloadsendsafely;

import com.sendsafely.ProgressInterface;

import java.text.MessageFormat;

public class ProgressCallback implements ProgressInterface {

  @Override
  public void updateProgress(String fileId, double progress) {
    System.out.print(MessageFormat.format(" {0,number,00.0%}\r", progress));
  }

  @Override
  public void gotFileId(String fileId) {
    System.out.println("Got File Id: " + fileId);
  }
}