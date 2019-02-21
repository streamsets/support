#!/bin/zsh

# This script start/stop Docker engine

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
    printf '\n Usage: ${0} [-start] [-stop] [-status] \n' >&2
    printf '  -start                    Start the Docker engine. \n' >&2
    printf '  -stop                     Stop the Docker engine \n' >&2
    printf '  -status                   Status of the Docker engine \n' >&2
  fi
  if [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
        echo "\n  Usage: ${0} \033[33;5;7m  [-start] [-stop] [-status]   \033[0m "  >&2
        echo "\033[33;5;7m\n-start   \033[0m     Start the Docker engine."  >&2
        echo "\033[33;5;7m\n-stop    \033[0m     Stop the Docker engine"  >&2
        echo "\033[33;5;7m\n-status  \033[0m     Status of the Docker engine"  >&2
        exit 1
  fi

}

if [[ $# -gt 2 ]]
then
  log 'Invalid arguments !!'
  usage
fi

ARG=$1

status(){
if [[ $ARG < 1 ]]
  then
    log 'Please provide an argument'
    usage
    exit 1
fi
docker system info
if [[ $? == 0 ]]
  then
    log 'Docker engine is running'
    exit 1
elif [[ $? == 1 ]]; then
  log 'Docker engine is not running'
  exit 1
fi
}

# Function to start the Docker engine
start(){
if [[ $ARG < 1 ]]
  then
    log 'Please provide an argument'
    usage
    exit 1
fi
open --background -a Docker
}

# Function to stop the Docker engine
stop(){
if [[ $ARG < 1 ]]
  then
    log 'Please provide an argument'
    usage
    exit 1
fi
docker ps -q | xargs -L1 docker stop
test -z "$(docker ps -q 2>/dev/null)" && osascript -e 'quit app "Docker"'
}
case "$1" in
# Start Docker engine
'start')
       start
       ;;
'stop')
# Stop Docker engine
      stop
      ;;
'status')
# Stop Docker engine
      status
      ;;
#prints command usage in case of bad arguments
  *) usage
    ;;
esac
exit $EXIT_STATUS
