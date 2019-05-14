package com.hive.jdbcclient;

import java.sql.SQLException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.DriverManager;

import org.apache.commons.cli.*;
import org.apache.commons.cli.CommandLine;

public class HiveJdbcClient {
    private static String driverName = "org.apache.hive.jdbc.HiveDriver";

    /**
     * @param args
     * @throws SQLException
     */
    public static void main(String[] args) throws SQLException {
        try {
            Class.forName(driverName);
        } catch (ClassNotFoundException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            System.exit(1);
        }
        Options options = new Options();

        Option HiveJDBCURL = new Option("URI", "HiveJDBCURL", true, "Hive JDBC URL(eg: jdbc:hive2://node-1.cluster:10000/default");
        HiveJDBCURL.setRequired(true);
        options.addOption(HiveJDBCURL);

        Option HiveUser = new Option("user", "HiveUser", true, "Hive user");
        HiveUser.setRequired(true);
        options.addOption(HiveUser);

        Option HivePassword = new Option("p", "HivePassword", true, "Hive Password");
        HivePassword.setRequired(true);
        options.addOption(HivePassword);

        String hiveURI = "", hiveUser = "", hivePassword = "";
        HelpFormatter formatter = new HelpFormatter();

        try {
            CommandLineParser parser = new DefaultParser();
            CommandLine cmd = parser.parse(options, args);
            hiveURI = cmd.getOptionValue("HiveJDBCURL");
            hiveUser = cmd.getOptionValue("HiveUser");
            hivePassword = cmd.getOptionValue("HivePassword");
        } catch (ParseException e) {
            System.out.println(e.getMessage());
            formatter.printHelp("HiveJdbcClient", options);

            System.exit(1);
        }

        try {
            Connection con = DriverManager.getConnection(hiveURI, hiveUser, hivePassword);
            Statement stmt = con.createStatement();
            String tableName = "testHiveDriverTable";
            System.out.println("Dropping table if exists...."+"\n");
            stmt.execute("drop table if exists " + tableName);
            System.out.println("Creating table "+tableName+"...."+"\n");
            stmt.execute("create table " + tableName + " (key int, value string)");
            // show tables
            // String sql = "show tables '" + tableName + "'";
            System.out.println("Executing <show tables>...."+"\n");
            String sql = ("show tables");
            ResultSet res = stmt.executeQuery(sql);
            if (res.next()) {
                System.out.println(res.getString(1));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

    }
}
