#!/bin/bash

YELLOW='\033[1;33m'
NC='\033[0m' # No Color
#prints command usage

log() {
if [[ "$OSTYPE" == "linux-gnu" ]]; then
      printf "\n ${YELLOW}$1${NC} \n\n"  # Linux
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "\033[33;5;7m\n $1 \n\033[0m" # Mac OSX
fi
}

usage() {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then # Linux
    printf '\n Usage: ${0} [-p] [-c] [-d] \n' >&2
    printf '  -p                    Java process ID \n' >&2
    printf '  -c                     # of thread dumps to collect \n' >&2
    printf '  -d                   Delay(secs) between thread dumps \n' >&2
    exit 1
  fi

  if [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
        echo "\n  Usage: ${0} \033[33;5;7m  [-p] [-c] [-d]   \033[0m "  >&2
        echo "\033[33;5;7m\n-p   \033[0m     Java process ID."  >&2
        echo "\033[33;5;7m\n-c    \033[0m     # of thread dumps to collecte"  >&2
        echo "\033[33;5;7m\n-d  \033[0m     Delay(secs) between thread dump"  >&2
        exit 1
  fi

}
if [[ ($# -lt 1) || $# -gt 3 ]]
    then
        log 'Invalid arguments !!'
        usage
fi
count=5  # defaults to 5 times
delay=10 # defaults to 10 seconds

while getopts ":p:c:d:" opt; do
  case ${opt} in
    p ) pid=$OPTARG # required
      ;;
    c ) count=$OPTARG
      ;;
    d ) delay=$OPTARG
      ;;
    \? ) usage
         exit 1
      ;;
  esac
done


while [[ $count -gt 0 ]]
do
    echo $count
    jstack -l $pid >jstack.$pid.$(date +%H%M%S.%N)
    sleep $delay
    let count--

done

