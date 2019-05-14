#!/bin/bash

#The following script helps to spot a timeline gap in the log

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
    printf '\n Usage: ${0} [<filename>] \n' >&2
    printf '  -filename                    log file to analyze. \n' >&2
    exit 1
  fi

  if [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
        echo "\n  Usage: ${0} \033[33;5;7m  [-p] [-c] [-d]   \033[0m "  >&2
        echo "\033[33;5;7m\n-<filename>   \033[0m    log file to analyze."  >&2
        exit 1
  fi

}
if [[ $# -lt 1 ]]
    then
        log 'Invalid arguments !!'
        usage
fi

filename=$1

awk 'BEGIN{ threshold=177} /^20[0-9][0-9]/{ if(!length(curr_time)){ split($1, d, "-") ; split($2, t, ":") ; curr_time = mktime(d[1] " " d[2] " " d[3] " " t[1] " " t[2] " " t[3]); curr_line=$0 } else{ split($1, d, "-") ;split($2, t, ":"); prev_time = curr_time; prev_line=curr_line ;curr_time = mktime(d[1] " " d[2] " " d[3] " " t[1] " " t[2] " " t[3]); curr_line=$0 ; gap = curr_time-prev_time; if(gap > threshold) { printf "=====Line %d =========================================================================\n", NR; print prev_line; print " | " ; printf " %d seconds gap\n",gap ; print " | " ; print curr_line ; flag=1 } } } END { if(flag!=1){print "No pauses found in log"}}'   $filename
