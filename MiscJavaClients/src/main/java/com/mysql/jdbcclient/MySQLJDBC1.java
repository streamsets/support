package com.mysql.jdbcclient;

import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.ResultSet;

public class MySQLJDBC {

    public static void main(String[] args) {

        String mySQLURL = "jdbc:mysql://localhost:3306/default?useSSL=false";
        String mySQLUser = "root";
        String mySQLPassword = "matrix007";
        String query = "SELECT VERSION()";

        try {
            Class.forName("com.mysql.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("No suitable driver found");
            e.printStackTrace();
            return;
        }

        System.out.println("MySQL JDBC Driver Registered!");
        Connection connection = null;

        try {
            connection = DriverManager
                    .getConnection(mySQLURL, mySQLUser, mySQLPassword);
            if (connection != null) {
                System.out.println("Database connection successful");
                Statement st = con.createStatement();
                ResultSet rs = st.executeQuery(query);

                if (rs.next()) {

                    System.out.println(rs.getString(1));
                } else {
                    System.out.println("Database connection failed !!");
                }
            }

        } catch (SQLException e) {
            System.out.println("Connection Failed! Check output console");
            e.printStackTrace();
            return;
        }
    }
}
