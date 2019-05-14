package com.main.app;

import com.cassandra.jdbcclient.CassandraCql;
import com.hive.jdbcclient.HiveJdbcClient;
import com.mapr.examples.Consumer;
import com.mapr.examples.Producer;

import java.io.IOException;
import java.sql.SQLException;

import org.apache.commons.cli.*;

/**
 * Picks the options we want to run. This lets us
 * have a single executable as a build target.
 */
public class Run {
    public static void main(String[] args) throws IOException, SQLException {
        HelpFormatter formatter = new HelpFormatter();
        Options options = new Options();
        if (args.length < 1) {

            Option runOptionProducer = new Option("producer", "MapR-Producer", true, "Publishes messages to MapR Streams topic");
            runOptionProducer.setRequired(true);
            options.addOption(runOptionProducer);

            Option runOptionConsumer = new Option("consumer", "MapR-Consumer", true, "Consume messages from MapR Streams topic");
            runOptionConsumer.setRequired(true);
            options.addOption(runOptionConsumer);

            Option hiveOptions = new Option("hive", "HiveJDBCClient", true, "Creates a test table on Hive");
            hiveOptions.setRequired(true);
            options.addOption(hiveOptions);

            Option cassandraOptions = new Option("cassandra", "cassandraJDBCClient", true, "Runs bunch of CRUD operations on Casandra");
            cassandraOptions.setRequired(true);
            options.addOption(cassandraOptions);


            try {
                CommandLineParser parser = new DefaultParser();
                CommandLine cmd = parser.parse(options, args);
            } catch (ParseException e) {
                System.out.println(e.getMessage());
                formatter.printHelp("Run", options);
                System.exit(1);
            }

        }
        switch (args[0]) {
            case "producer":
                Producer.main(args);
                break;
            case "consumer":
                Consumer.main(args);
                break;
            case "hive":
                HiveJdbcClient.main(args);
                break;
            case "cassandra":
                CassandraCql.main(args);
                break;
            default:
                System.out.println("Invalid option:  " + args[0]);
                formatter.printHelp("Run", options);
                System.exit(1);
        }
    }
}