#!/bin/bash

SS_BIN_DIR='/Users/sanjeev/SDC/streamsets-datacollector-3.3.1/bin'
SS_URL='http://localhost:18630'
SDC_USER='admin'
SDC_PWD='LeN2$BcF!3CH'
PIPELINE_ID=$1


printf "Starting Pipeline %s ${1}"
# Example ~/SDC/streamsets-datacollector-3.3.1/bin/streamsets cli -U http://localhost:18630 -u admin -p 'admin' manager start -n LoadData20289d0b-a1ab-40a8-9445-ea2ed12261f3
pipeline_start(){
${SS_BIN_DIR}/streamsets cli -U ${SS_URL} -u ${SDC_USER} -p ${SDC_PWD} manager start -n ${PIPELINE_ID}
}
pipeline_start