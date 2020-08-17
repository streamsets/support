package com.streamsets.kbsummary;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class Database implements AutoCloseable {

  private static final Logger LOG = LoggerFactory.getLogger(Database.class);

  private static final String EXCEPTION_STRING = "Exception {} :";
  private SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
  Connection conn;
  PreparedStatement preparedStatement;

  public Database(String connectionString, String userName, String password) {
    String stmt = "INSERT INTO kb_usage (ticket_id, kb_article_url, link_hash, date_linked)";
    stmt += "VALUES (?, ?, ?, ?)";


    try {
      conn = DriverManager.getConnection(connectionString, userName, password);
      preparedStatement = conn.prepareStatement(stmt);

    } catch (SQLException ex) {
      LOG.error(EXCEPTION_STRING, ex.getMessage(), ex);
      System.exit(10);
    }

  }

  void insertKB(long ticketId, String link, String digestString, Date dateLinked) {

    try {
      preparedStatement.setLong(1, ticketId);
      preparedStatement.setString(2, link);
      preparedStatement.setString(3, digestString);

      String dt = sdf.format(dateLinked);
      preparedStatement.setString(4, dt);
      preparedStatement.executeUpdate();

    } catch(SQLIntegrityConstraintViolationException ex) {
      //no worries.   duplicate.

    } catch(SQLException ex){
      LOG.error("SQLException {}", ex.getMessage(), ex);
      System.exit(2);
    }
  }

  @Override
  public void close() {
    try {
      if (preparedStatement != null) {
        preparedStatement.close();
      }
      if (conn != null) {
        conn.close();
      }
    } catch (SQLException ex) {
      LOG.info("error closing resource {}", ex.getMessage(), ex);
    }
  }
}
