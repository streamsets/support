#!/bin/bash

# Run before a fresh build to avoid ending up duplicate packages

find ~/workspace/datacollector/ -iname "target" -exec rm -rf {} \;
cd ~/workspace/datacollector/
mvn package -Pdist,ui -DskipTests -DskipRat
# may need to build datacollector-api again