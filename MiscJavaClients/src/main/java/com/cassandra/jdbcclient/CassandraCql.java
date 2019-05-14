package com.cassandra.jdbcclient;

import org.apache.commons.cli.*;
import org.apache.commons.cli.CommandLine;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;



public class CassandraCql {
    private static java.sql.Connection con = null;

    public static void main(String[] args){

        Options options = new Options();

        Option CassandraJDBCURL = new Option("uri", "CassandraJDBCURL", true, "Cassandra JDBC URL(eg: jdbc:cassandra://localhost:9160/<keyspace>");
        CassandraJDBCURL.setRequired(true);
        options.addOption(CassandraJDBCURL);

        CommandLineParser parser = new DefaultParser();
        HelpFormatter formatter = new HelpFormatter();
        String cassandraURI="";

        try {
            CommandLine cmd = parser.parse(options, args);
            cassandraURI = cmd.getOptionValue("CassandraJDBCURL");
        } catch (ParseException e) {
            System.out.println(e.getMessage());
            formatter.printHelp("utility-name", options);

            System.exit(1);
        }

        try {
            Class.forName("org.apache.cassandra.cql.jdbc.CassandraDriver");
            con=DriverManager.getConnection(cassandraURI);
            CassandraCql sample = new CassandraCql();
            String Columnname="subject";

            /* -- Functions to perform on Keyspace --*/
            createColumnFamily();
            pouplateData();
            deleteData();
            updateData();
            listData();
            dropColumnFamily("news");

        } catch (ClassNotFoundException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } catch (SQLException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }


    public static void createColumnFamily() throws SQLException {
        String data="CREATE columnfamily news (key int primary key, category text , linkcounts int ,url text)";
        Statement st = con.createStatement();
        st.execute(data);
    }

    public static void dropColumnFamily(String name) throws SQLException {
        String data="drop columnfamily "+ name +";";
        Statement st = con.createStatement();
        st.execute(data);
    }

    public static void pouplateData() throws SQLException {
        String data=
                "BEGIN BATCH \n"+
                        "insert into news (key, category, linkcounts,url) values ('user5','class',71,'news.com') \n"+
                        "insert into news (key, category, linkcounts,url) values ('user6','education',15,'tech.com') \n"+
                        "insert into news (key, category, linkcounts,url) values ('user7','technology',415,'ba.com') \n"+
                        "insert into news (key, category, linkcounts,url) values ('user8','travelling',45,'google.com/teravel') \n"+
                        "APPLY BATCH;";
        Statement st = con.createStatement();
        st.executeUpdate(data);
    }
    public static void deleteData() throws SQLException {
        String data=
                "BEGIN BATCH \n"+
                        "delete from  news where key='user5' \n"+
                        "delete  category from  news where key='user2' \n"+
                        "APPLY BATCH;";
        Statement st = con.createStatement();
        st.executeUpdate(data);
    }
    public static void updateData() throws SQLException {
        String t = "update news set category='sports', linkcounts=1 where key='user5'";
        Statement st = con.createStatement();
        st.executeUpdate(t);
    }
    public static void listData() throws SQLException {
        String t = "SELECT * FROM news";
        Statement st = con.createStatement();
        ResultSet rs = st.executeQuery(t);
        while(rs.next())
        {
            System.out.println(rs.getString("KEY"));
            for(int j=1;j<rs.getMetaData().getColumnCount()+1;j++)
            {
                System.out.println(rs.getMetaData().getColumnName(j) +" : "+rs.getString(rs.getMetaData().getColumnName(j)));
            }
        }
    }

}
