<img src="/images/readme.png" align="right" />

#                                       MapR Streams
## Java producer/consumer client for MapR streams

For more details please refer to the source blog: https://mapr.com/blog/getting-started-sample-programs-mapr-streams/

#####Step 1: Create the stream
        Run the following command, as mapr user, on your MapR cluster:

        $ maprcli stream create -path /sample-stream
        
To make all of the topics available to anybody (public permission), you can run the following command:

        $ maprcli stream edit -path /sample-stream -produceperm p -consumeperm p -topicperm p
        
#####Step 2: Create the topics
        We need two topics for the example program, which we can be created using maprcli:

        $ maprcli stream topic create -path /sample-stream  -topic fast-messages
        $ maprcli stream topic create -path /sample-stream  -topic summary-markers
        
These topics can be listed using the following command:

        $ maprcli stream topic list -path /sample-stream
        topic            partitions  logicalsize  consumers  maxlag  physicalsize
        fast-messages    1           0            0          0       0
        summary-markers  1           0            0          0       0

#####[OPTIONAL] Step 3: Compile and package the example programs
            ** You can use the pre-built jars from this repo. If you want to re-build:
            Git clone https://github.com/mapr-demos/mapr-streams-sample-programs
            Go to the directory where you have the example programs and build the example programs.

            $ cd ..
            $ mvn package
            ...
The project creates a jar with all external dependencies ( ./target/mapr-streams-examples-1.0-SNAPSHOT-jar-with-dependencies.jar )

#####Step 4: Run the example producer
        You can install the MapR Client and run the application locally, or copy the jar file onto your cluster (any node). 
        If you are installing the MapR Client be sure you also install the MapR Kafka package using the following command on CentOS/RHEL :
        
        yum install mapr-kafka
        
        $ scp ./target/mapr-streams-examples-1.0-SNAPSHOT-jar-with-dependencies.jar mapr@<YOUR_MAPR_CLUSTER>:/home/mapr
        The producer will send a large number of messages to /sample-stream:fast-messages along with occasional messages to /sample-stream:summary-markers. Since there isn't any consumer running yet, nobody will receive the messages.
        
        If you compare this with the Kafka example used to build this application, the topic name is the only change to the code.
        
        Any MapR Streams application will need the MapR Client libraries. One way to make these libraries available to add them to the application classpath using the /opt/mapr/bin/mapr classpath command. For example:
        
        $ java -cp $(mapr classpath):./mapr-streams-examples-1.0-SNAPSHOT-jar-with-dependencies.jar com.javaclients.run.Run producer
        Sent msg number 0
        Sent msg number 1000
        ...
        Sent msg number 998000
        Sent msg number 999000

#####Step 5: Start the example consumer
        In another window, you can run the consumer using the following command:

        $ java -cp $(mapr classpath):./mapr-streams-examples-1.0-SNAPSHOT-jar-with-dependencies.jar com.javaclients.run.Run consumer
        1 messages received in period, latency(min, max, avg, 99%) = 20352, 20479, 20416.0, 20479 (ms)
        1 messages received overall, latency(min, max, avg, 99%) = 20352, 20479, 20416.0, 20479 (ms)
        1000 messages received in period, latency(min, max, avg, 99%) = 19840, 20095, 19968.3, 20095 (ms)
        1001 messages received overall, latency(min, max, avg, 99%) = 19840, 20479, 19968.7, 20095 (ms)
        ...
        1000 messages received in period, latency(min, max, avg, 99%) = 12032, 12159, 12119.4, 12159 (ms)
        <998001 1000="" 12095="" 19583="" 999001="" messages="" received="" overall,="" latency(min,="" max,="" avg,="" 99%)="12032," 20479,="" 15073.9,="" (ms)="" in="" period,="" 12095,="" 12064.0,="" 15070.9,="" (ms)<="" pre="">

Note that there is a latency listed in the summaries for the message batches. This is because the consumer wasn't running when the messages were sent to MapR Streams, and thus it is only getting them much later, long after they were sent.

##### Monitoring your topics
At any time you can use the maprcli tool to get some information about the topic. For example:

    $ maprcli stream topic info -path /sample-stream -topic fast-messages -json

The `-json` option is used to get the topic information as a JSON document.

##### Cleaning up
When you are done playing, you can delete the stream and all associated topics using the following command:

    $ maprcli stream delete -path /sample-stream
    

#                                   Cassandra


## Simple JDBC Java client to perform basic CRUD operations

#####Step 1: Start the Cassandra server and open the Cassandra CLI. 

Create a Keyspace:
cqlsh> CREATE KEYSPACE <name>;

List the keyspaces:
cqlsh> describe keyspaces;

#####Step 2: Run the jar as below:



Source: http://niranjandubey.blogspot.com/2012/11/cassandra-jdbc-to-perform-crud.html


#                                   Hive

## Simple JDBC Java client to perform basic CRUD operations

creates a test table 'testHiveDriverTable' in 'default' database and execute "show tables" SQL

##### Run the jar as below:

