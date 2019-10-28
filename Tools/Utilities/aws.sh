  #!/bin/bash

#This script perform following operations on your AWS instance
#Status check
#Start instance
#Stop instance
#Update /etc/hosts file with your AWS instance information


SSH_KEY='~/.ssh/sanju.pem'
USERNAME='sanjeev-basis'  # Hard code this value for status command to work if running the script from a host where username will be different from your username
HostFile='/etc/hosts'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
#prints command usage

usage() {

  if [[ "$OSTYPE" == "linux-gnu" ]]; then # Linux
    printf '\n Usage: ${0} [-start] [-stop] [-status] [-setup] \n' >&2
    printf '  -start  <instance-name>                  Start the AWS instance. \n' >&2
    printf '  -stop    <instance-name>                 Stop the AWS instance \n' >&2
    printf '  -stopAll                                 Stop all of your AWS instances \n' >&2
    printf '  -status   [OPTIONAL] <instance-name>     Status of the AWS instance \n' >&2
    printf '  -setup <your-name>                       Updates /etc/hosts file with your AWS instances \n' >&2
    printf '                                         <your-name>  == Owner TAG on your AWS instances \n'  >&2
  fi
  if [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
        echo -e "\n  Usage: ${0} \033[33;5;7m  [-start] [-stop] [-status] [-setup]   \033[0m "  >&2
        echo -e "\033[33;5;7m\n-start  <instance-name>\033[0m                  Start the AWS instance."  >&2
        echo -e "\033[33;5;7m\n-stop    <instance-name>\033[0m                 Stop the AWS instance"  >&2
        echo -e "\033[33;5;7m\n-stopAll   \033[0m                              Stop all of your AWS instances"  >&2
        echo -e "\033[33;5;7m\n-status   [OPTIONAL] <instance-name>\033[0m     Status of the AWS instance"  >&2
        echo -e "\033[33;5;7m\n-setup <your-name>\033[0m                       Updates /etc/hosts file with your AWS instances"  >&2
        echo -e "                                         <your-name>  == Owner TAG on your AWS instances \n"  >&2
        exit 1
  fi


}

log() {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
        printf "\n ${YELLOW}$1${NC} \n\n"  # Linux
  fi
  if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e"\033[33;5;7m\n $1 \n\033[0m" # Mac OSX
  fi
}

if [[ $# -gt 2 ]]
  then
    log 'Invalid arguments !!'
    usage
fi

ARG=$2

# Function to check the status of the AWS instance
status(){
  if [[ $ARG < 1 ]]
  then
    echo -e "Querying status on all of your AWS instances...."
   for i in $(aws --output json ec2 describe-instances --filters "Name=tag:owner,Values=$USERNAME" | grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",");
   do
      echo -e "$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep name | awk '{print $3 "        ==> "}' | tr -d '\n')$(aws --output text ec2 describe-instances --instance-id $i | grep -w STATE | awk '{print $3}')"
   done
 elif [[ $ARG > 1 ]]
     then
       HOSTNAME=$ARG
       AWS_HOSTNAME=$(cat /etc/hosts | grep -i $HOSTNAME |  awk '{print $3}')
       PUBLIC_AWS_HOSTNAME=$(cat /etc/hosts | grep -i $HOSTNAME |  awk '{print $2}')
       INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
       if [[ -z "${AWS_HOSTNAME// }" ]]
          then
            log 'Host not found in /etc/hosts file. Please verify the hostname'
            exit 1
       fi
       echo -e "Querying status of <$ARG> instance"
       #INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
       STATUS=$(aws --output text ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
        if [[ $STATUS = 'running' ]]
        then
           log 'Instance is running'
        else
            log 'Instance is not running'
          fi
   fi
}
# Function to start the AWS instance
start(){
  if [[ $ARG < 1 ]]
    then
      log 'Please provide instance name'
      usage
      exit 1
  fi

 HOSTNAME=$ARG
 AWS_HOSTNAME=$(cat /etc/hosts | grep -i $HOSTNAME |  awk '{print $3}')
 PUBLIC_AWS_HOSTNAME=$(cat /etc/hosts | grep -i $HOSTNAME |  awk '{print $2}')
 INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
 NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" | grep TAGS | grep name | awk '{print $3}')

 if [[ -z "${AWS_HOSTNAME// }" ]]
    then
      log 'Host not found in /etc/hosts file. Please verify the hostname'
      exit 1
    else
      #INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
      STATUS=$(aws --output text ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
       if [[ $STATUS = 'running' ]]
       then
          log 'Instance is already running'
          exit 1
       fi
 fi

 #INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
 echo -e "\nStarting: \033[33;5;7m $INSTANCE_ID --> ($NAME_TAG) \033[0m"
 aws ec2 start-instances --instance-ids $INSTANCE_ID
 SSH_EXIT_STATUS=$?
 if [[ $SSH_EXIT_STATUS -ne 0 ]]
    then
          EXIT_STATUS=$SSH_EXIT_STATUS
              log 'Error in starting the instnace....'
            else
              sleep 10
              echo -e "\033[33;5;7m\n $INSTANCE_ID --> ($NAME_TAG) \033[0m started successfully !!"
              echo -e "Please login to your instance using the command: ssh -i $SSH_KEY ubuntu@$PUBLIC_AWS_HOSTNAME\n"
            fi
}

# Function to stop the AWS instance
stop(){
  if [[ $ARG < 1 ]]
    then
      log 'Please provide name of the instance to stop'
      usage
      exit 1
  elif  [[ $ARG > 1 ]]
    then
      HOSTNAME=$ARG
      AWS_HOSTNAME=$(cat /etc/hosts | grep -i $HOSTNAME |  awk '{print $3}')
      PUBLIC_AWS_HOSTNAME=$(cat /etc/hosts | grep -i $HOSTNAME |  awk '{print $2}')
      INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")

      if [[ -z "${AWS_HOSTNAME// }" ]]
         then
           log 'Host not found in /etc/hosts file. Please verify the hostname'
           exit 1
         else
           #INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
           STATUS=$(aws --output text ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
            if [[ -z "${STATUS// }" ]]
            then
               log "Instance is already stopped"
               exit 1
            fi
      fi
      echo -e "Stopping your <$ARG> instance...."
      #INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
      aws ec2 stop-instances --instance-ids $INSTANCE_ID
      SSH_EXIT_STATUS=$?
        if [[ $SSH_EXIT_STATUS -ne 0 ]]
           then
                 EXIT_STATUS=$SSH_EXIT_STATUS
                 log 'Error in Stopping the instance....'
        fi
  fi
}
stopAll(){
  aws --output json ec2 describe-instances --filters "Name=tag:owner,Values=$USERNAME" |grep "PrivateDnsName" | awk '{print $2}' | sort | uniq | tr -d "\"" | tr -d "," > ~/AWS.txt
  while read line
   do
     AWS_HOSTNAME=$line
     INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
     NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" | grep TAGS | grep name | awk '{print $3}')
     STATUS=$(aws --output text ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
      if [[ $STATUS = 'running' ]]
      then
        echo -e "Stopping \033[33;5;7m\n $INSTANCE_ID --> ($NAME_TAG)... \033[0m"
         aws ec2 stop-instances --instance-ids $INSTANCE_ID
         SSH_EXIT_STATUS=$?
           if [[ $SSH_EXIT_STATUS -ne 0 ]]
              then
                    EXIT_STATUS=$SSH_EXIT_STATUS
                    log 'Error in Stopping the instance....'
           fi
      else
          echo -e "\033[33;5;7m\n $INSTANCE_ID --> ($NAME_TAG) \033[0m already stopped. Skipping to next..."
      fi
  done < AWS.txt
  rm -f AWS.txt
  log 'All of your AWS instances stopped'
}
setup(){
  log 'Finding your AWS instances....'
  if [[ $ARG < 1 ]]
    then
      log 'Please provide the owner tag for your AWS instance'
      usage
      exit 1
  fi
  if  [[ $ARG > 1 ]]
    then
      OWNER=$ARG
      INSTANCE_FOUND=$(aws --output text ec2 describe-instances --filters "Name=tag:owner,Values=$OWNER")
        if [[ -z "${INSTANCE_FOUND// }" ]]
          then
           log 'No AWS instances found with supplied owner tag. Please verify the tag'
           exit 1
         else
           NUM_INSTANCES=$(aws --output json ec2 describe-instances --filters "Name=tag:owner,Values=$OWNER" | grep "PrivateIpAddress" | awk '{print $2}' | tr -d "\"" | tr -d "," | tr -d "[" | sort | uniq | sed '/^\s*$/d' | wc -l)
           aws --output json ec2 describe-instances --filters "Name=tag:owner,Values=$OWNER" |grep "PrivateDnsName" | awk '{print $2}' | sort | uniq | tr -d "\"" | tr -d "," > ~/AWS.txt
           while read line
            do
              HOSTNAME=$line
              HOST_IP=$(echo -e ${HOSTNAME%%.*} | sed -e 's/ip-//' -e 's/-/./g')
              NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$HOSTNAME" | grep TAGS | grep name | awk '{print $3}')
              HOST_IN_ETC=$(grep $HOSTNAME $HostFile)

              if [[  -z "${HOST_IN_ETC// }" ]]
              then
                sudo bash -c "echo -e $HOST_IP  $HOSTNAME $NAME_TAG >> /etc/hosts"
              else
                echo -e "\033[33;5;7m\n $HOSTNAME \033[0m alreasy exists in /etc/hosts file. skipping..."

              fi
           done < AWS.txt
           rm -f AWS.txt
        fi
  fi
}

case "$1" in
  #start the AWS instance
	'start')
         start
  		   ;;

  'stop')
        #stop the AWS instance
        stop
	      ;;

  'stopAll')
        #stop the AWS instance
        stopAll
        ;;

	'status')
        #Query the status on the AWS instance
        status
        ;;

    'setup')
        # Updates /etc/hosts file with your AWS instance IP/HOSTNAME
        setup
       ;;

  #prints command usage in case of bad arguments
    *) usage
      ;;
esac
exit $EXIT_STATUS
