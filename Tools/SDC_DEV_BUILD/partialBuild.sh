#!/bin/bash

## Partial build utility- add as zshell function

function pbld {
  if [ $# -eq 1 ]; then
    cd $1
  fi
  if [ ! -d ../dist/ ]; then
    echo "Directory ../dist/ doesn't exists, running from the right sub-directory?"
    return
  fi
  echo "Building the project"
  mvn package -Drelease -DskipTests
  if [ $? -ne 0 ]; then
    echo "Build failed"
    return
  fi
  jar=`find target -iname 'streamsets-datacollector-*.jar' -maxdepth 1 -not -iname '*-tests.jar' -exec basename {} \; `
  echo "Working on jar: $jar"
  count=0
  for target in `find ../dist/target -iname $jar`; do
    echo "Replacing $target"
    cp target/$jar $target
    count=`expr $count + 1`
  done
  if [[ "$count" -eq 0 ]]; then
    "Did not found the $jar inside release build, is the build correctly built?"
    return
  fi
  if [ $# -eq 1 ]; then
    cd ..
  fi
}