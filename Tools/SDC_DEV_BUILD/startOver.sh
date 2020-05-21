#!/usr/bin/env bash

#!/bin/bash
rm -rf datacollector-api
git clone https://review.streamsets.net/datacollector-api
cd datacollector-api
git fetch --tags
git remote rm origin
git remote add origin ssh://bob@review.streamsets.net:29418/datacollector-api
scp -p -P 29418 bob@review.streamsets.net:hooks/commit-msg .git/hooks/
##mvn clean package -DskipTests  -DskipRat
##mvn clean install -DskipTests -DskipRat
cd ..
##
rm -rf datacollector
git clone https://review.streamsets.net/datacollector
cd datacollector
git fetch --tags
git remote rm origin
git remote add origin ssh://bob@review.streamsets.net:29418/datacollector
scp -p -P 29418 bob@review.streamsets.net:hooks/commit-msg .git/hooks/
##mvn clean package -DskipTests -DskipRat
##mvn clean install -DskipTests -DskipRat