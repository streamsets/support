package com.mysql.jdbcclient;

import org.apache.commons.cli.*;
import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.SQLException;

public class MySQLJDBC {

    public static void main(String[] args) {

        try {
            Class.forName("com.mysql.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("No suitable driver found");
            e.printStackTrace();
            return;
        }

        System.out.println("MySQL JDBC Driver Registered!");
        Connection connection = null;

        Options options = new Options();

        Option mySQL_JDBC_URL = new Option("URL", "MySQL JDBC URL", true, "MySQQL JDBC URL(eg: jdbc:mysql://localhost:3306/default");
        mySQL_JDBC_URL.setRequired(true);
        options.addOption(mySQL_JDBC_URL);

        Option mySQL_User = new Option("user", "DB User", true, "MySQL database user");
        mySQL_User.setRequired(true);
        options.addOption(mySQL_User);

        Option mySQL_Password = new Option("p", "DB Password", true, "MySQL database Password");
        mySQL_Password.setRequired(true);
        options.addOption(mySQL_Password);

        String mySQLURL = "", mySQLUser = "", mySQLPassword = "";
        HelpFormatter formatter = new HelpFormatter();

        try {
            CommandLineParser parser = new DefaultParser();
            CommandLine cmd = parser.parse(options, args);
            mySQLURL = cmd.getOptionValue("mySQL_JDBC_URL");
            mySQLUser = cmd.getOptionValue("mySQL_User");
            mySQLPassword = cmd.getOptionValue("mySQL_Password");
        } catch (ParseException e) {
            System.out.println(e.getMessage());
            formatter.printHelp("MySQLJDBC", options);

            System.exit(1);
        }

        try {
            connection = DriverManager
                    .getConnection(mySQLURL,mySQLUser, mySQLPassword);

        } catch (SQLException e) {
            System.out.println("Connection Failed! Check output console");
            e.printStackTrace();
            return;
        }

        if (connection != null) {
            System.out.println("Database connection successful");
        } else {
            System.out.println("Database connection failed !!");
        }
    }
}
