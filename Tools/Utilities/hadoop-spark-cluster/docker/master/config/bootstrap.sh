#!/bin/bash

service ssh start

# start cluster
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user
$HADOOP_HOME/bin/hdfs dfs -mkdir /spark-logs

# start  Transformer
/opt/streamsets-transformer-3.13.0/bin/streamsets transformer &

# start spark history server
$SPARK_HOME/sbin/start-history-server.sh

bash
