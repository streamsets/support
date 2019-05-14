#!/bin/bash
export SDC_VERSION=3.9.0-SNAPSHOT
: "${SDC_VERSION? Need to set SDC_VERSION}"

# Clean logs/sysmlinks and start new logs
rm ~/workspace/datacollector/dist/target/streamsets-datacollector-${SDC_VERSION}/streamsets-datacollector-${SDC_VERSION}/log/sdc.log*
touch ~/workspace/datacollector/dist/target/streamsets-datacollector-${SDC_VERSION}/streamsets-datacollector-${SDC_VERSION}/log/sdc.log
rm ~/SDC/libexec
rm ~/SDC/etc

# Kill any tail commands to log file

killall tail
tail -f ~/workspace/datacollector/dist/target/streamsets-datacollector-${SDC_VERSION}/streamsets-datacollector-${SDC_VERSION}/log/sdc.log &

#export SDC_HOME=$(pwd)/dist/target/streamsets-datacollector-${SDC_VERSION}/streamsets-datacollector-${SDC_VERSION}
export SDC_HOME=~/workspace/datacollector/dist/target/streamsets-datacollector-${SDC_VERSION}/streamsets-datacollector-${SDC_VERSION}
echo $SDC_HOME
export SDC_CONF=${SDC_HOME}/etc
echo $SDC_CONF
export SDC_DATA=${SDC_HOME}/data
echo $SDC_DATA

##dist/target/streamsets-datacollector-${SDC_VERSION}/streamsets-datacollector-${SDC_VERSION}/bin/streamsets setup-mapr

# Create symlinks for /etc and /libexec for easy navigation to SDC configs

ln -s ~/workspace/datacollector/dist/target/streamsets-datacollector-${SDC_VERSION}/streamsets-datacollector-${SDC_VERSION}/etc ~/SDC/etc
ln -s ~/workspace/datacollector/dist/target/streamsets-datacollector-${SDC_VERSION}/streamsets-datacollector-${SDC_VERSION}/libexec ~/SDC/libexec

# Launch SDC
~/workspace/datacollector/dist/target/streamsets-datacollector-${SDC_VERSION}/streamsets-datacollector-${SDC_VERSION}/bin/streamsets dc
