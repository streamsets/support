  #!/bin/bash

#This script perform following operations on your AWS instance
#Status check
#Start instance
#Stop instance
#Update /etc/hosts file with your AWS instance information


SSH_KEY='~/.ssh/sanju.pem'
USERNAME='sanjeev-basis'  # Hard code this value for status command to work if running the script from a host where username will be different from your username
HostFile='/etc/hosts'
YELLOW='\033[1;33m' # Foreground Yellow
BC_YELLOW='\033[33;5;7m' #Backgroud Yellow
NC='\033[0m' # No Color

#prints command usage
usage() {

  if [[ "$OSTYPE" == "linux-gnu" ]]; then # Linux
        echo -e  "\n  Usage: ${0} ${BC_YELLOW}  [start] [stop] [status] [reaper] [setup]   ${NC} "  >&2
        echo -e  "${BC_YELLOW}\n start  <instance-name>${NC}                  Start the AWS instance."  >&2
        echo -e  "${BC_YELLOW}\n stop    <instance-name>${NC}                 Stop the AWS instance"  >&2
        echo -e  "${BC_YELLOW}\n stopAll   ${NC}                              Stop all of your AWS instances"  >&2
        echo -e  "${BC_YELLOW}\n status   [OPTIONAL] <instance-name>${NC}     Status of the AWS instance"  >&2
        echo -e  "${BC_YELLOW}\n reaper ${NC}                                 Stop the instances with aws-reaper tag ON"  >&2
        echo -e  "${BC_YELLOW}\n tag [OPTIONAL] <instance-name> on/off${NC}   Add aws-reaper tag to the AWS instances"  >&2
        echo -e  "${BC_YELLOW}\n setup <AWS-OWNER-TAG>${NC}                       Updates the /etc/hosts file with the name tag on your AWS instances"  >&2
        echo -e  "                                         <your-name>  == Owner TAG on your AWS instances \n"  >&2
  fi
  if [[ "$OSTYPE" == "darwin"* ]]; then # Mac OSX
        echo  "\n  Usage: ${0} ${BC_YELLOW}  [start] [stop] [status] [reaper] [setup]   ${NC} "  >&2
        echo  "${BC_YELLOW}\n start  <instance-name>${NC}                  Start the AWS instance."  >&2
        echo  "${BC_YELLOW}\n stop    <instance-name>${NC}                 Stop the AWS instance"  >&2
        echo  "${BC_YELLOW}\n stopAll   ${NC}                              Stop all of your AWS instances"  >&2
        echo  "${BC_YELLOW}\n status   [OPTIONAL] <instance-name>${NC}     Status of the AWS instance"  >&2
        echo  "${BC_YELLOW}\n reaper ${NC}                                 Stop the instances with aws-reaper tag ON"  >&2
        echo  "${BC_YELLOW}\n tag [OPTIONAL] <instance-name> on/off ${NC}  Add aws-reaper tag to the AWS instances"  >&2
        echo  "${BC_YELLOW}\n setup <AWS-OWNER-TAG>${NC}                       Updates the /etc/hosts file with the name tag on your AWS instances"  >&2
        echo  "                                         <your-name>  == Owner TAG on your AWS instances \n"  >&2
  fi
}

log() {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
        echo -e "\n ${YELLOW}$1${NC} \n"  # Linux
  fi
  if [[ "$OSTYPE" == "darwin"* ]]; then
        echo  "${YELLOW}\n $1 \n${NC}" # Mac OSX
  fi
}
write() {
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
        echo -e "$1"  # Linux
  fi
  if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "$1"  # Mac OSX
  fi
}

NUM_ARG=$#
ARG=$2
ARG1=$3


# Function to check the status of the AWS instance
status(){
  HOSTNAME=$ARG
  if [[ "$NUM_ARG" -ge 3 ]]
    then
        log "Invalid number of arguments !!"
        usage
    elif [[ "$NUM_ARG" -eq 1 ]]
        then
            write  "Querying status on all of your AWS instances...."
            for i in $(aws --output json ec2 describe-instances --filters "Name=tag:owner,Values=$USERNAME" | grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",");
                do
                    echo  "$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i name | awk '{print $3 "        ==> "}' | tr -d '\n')$(aws --output text ec2 describe-instances --instance-id $i | grep -w STATE | awk '{print $3}')"
                done
    elif [[ "$NUM_ARG" -eq 2 ]]
        then
            AWS_HOSTNAME=$(cat /etc/hosts | grep -w $HOSTNAME |  awk '{print $2}')
            INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
            if [[ -z "${AWS_HOSTNAME// }" ]]
                then
                    log 'Host not found in /etc/hosts file. Please verify the hostname'
                elif [[ -z "${INSTANCE_ID// }" ]]
                then
                    log 'AWS instance not found !!'
                else
                    NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" | grep TAGS | grep -i name | awk '{print $3}')
                    STATUS=$(aws --output text ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
                    if [[ $STATUS == 'running' ]]
                        then
                            log 'Instance is running'
                        else
                            log 'Instance is not running'
                fi
        fi
  fi
}
# Function to start the AWS instance
start(){
HOSTNAME=$ARG
  if [[ "$NUM_ARG" -ge 3 ]]
    then
        log "Invalid number of arguments !!"
        usage
    elif [[ "$NUM_ARG" -le 1 ]]
    then
        log 'Please provide instance name to stop'
        usage
    elif [[ "$NUM_ARG" -eq 2 ]]
    then
      AWS_HOSTNAME=$(cat /etc/hosts | grep -w $HOSTNAME |  awk '{print $2}')
      INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
      NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" | grep TAGS | grep -i name | awk '{print $3}')
      STATUS=$(aws --output text ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
      if [[ -z "${AWS_HOSTNAME// }" ]]
        then
            log 'Host not found in /etc/hosts file. Please verify the hostname'
        elif [[ -z "${INSTANCE_ID// }" ]]
            then
                log 'AWS instance not found !!'
            elif [[ $STATUS == 'running' ]]
                then
                    log 'Instance is already running'
                else
                    write "\nStarting: ${BC_YELLOW} $INSTANCE_ID --> ($NAME_TAG) ${NC}"
                    aws ec2 start-instances --instance-ids $INSTANCE_ID
                    SSH_EXIT_STATUS=$?
                    if [[ $SSH_EXIT_STATUS -ne 0 ]]
                        then
                            EXIT_STATUS=$SSH_EXIT_STATUS
                            log 'Error in starting the instance....'
                        else
                            sleep 10
                            write "${BC_YELLOW}\n $INSTANCE_ID --> ($NAME_TAG) ${NC} started successfully !!"
                            #write  "Please login to your instance using the command: ssh -i $SSH_KEY ubuntu@$PUBLIC_AWS_HOSTNAME\n"
                    fi

        fi
  fi

}

# Function to stop the AWS instance
stop(){
  HOSTNAME=$ARG
  if [[ "$NUM_ARG" -ge 3 ]]
    then
        log "Invalid number of arguments !!"
        usage
    elif [[ "$NUM_ARG" -le 1 ]]
    then
        log 'Please provide instance name to stop'
        usage
    elif [[ "$NUM_ARG" -eq 2 ]]
    then
      AWS_HOSTNAME=$(cat /etc/hosts | grep -w $HOSTNAME |  awk '{print $2}')
      INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
      NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" | grep TAGS | grep -i name | awk '{print $3}')
      STATUS=$(aws --output text ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
      if [[ -z "${AWS_HOSTNAME// }" ]]
        then
            log 'Host not found in /etc/hosts file. Please verify the hostname'
        elif [[ -z "${INSTANCE_ID// }" ]]
            then
                log 'AWS instance not found !!'
            elif [[ -z "${STATUS// }" ]]
                then
                    log 'Instance is already stopped'
                else
                    write "\nStopping: ${BC_YELLOW} $INSTANCE_ID --> ($NAME_TAG) ${NC}"
                    aws ec2 stop-instances --instance-ids $INSTANCE_ID
                    SSH_EXIT_STATUS=$?
                    if [[ $SSH_EXIT_STATUS -ne 0 ]]
                        then
                            EXIT_STATUS=$SSH_EXIT_STATUS
                            log 'Error in stopping the instance....'
                        else
                            sleep 10
                            write "${BC_YELLOW}\n $INSTANCE_ID --> ($NAME_TAG) ${NC} stopped successfully !!"
                            #write  "Please login to your instance using the command: ssh -i $SSH_KEY ubuntu@$PUBLIC_AWS_HOSTNAME\n"
                    fi

        fi
  fi

}
stopAll(){
if [[ "$NUM_ARG" -ge 2 ]]
    then
        log "Invalid number of arguments !!"
        usage
    elif [[ "$NUM_ARG" -eq 1 ]]
    then
        aws --output json ec2 describe-instances --filters "Name=tag:owner,Values=$USERNAME" |grep "PrivateDnsName" | awk '{print $2}' | sort | uniq | tr -d "\"" | tr -d "," > ~/AWS.txt
        while read line
            do
                AWS_HOSTNAME=$line
                INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
                NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" | grep TAGS | grep -i name | awk '{print $3}')
                STATUS=$(aws --output text ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
                if [[ $STATUS == 'running' ]]
                    then
                        write "Stopping ${BC_YELLOW}\n $INSTANCE_ID --> ($NAME_TAG)... ${NC}"
                        aws ec2 stop-instances --instance-ids $INSTANCE_ID
                        SSH_EXIT_STATUS=$?
                        if [[ $SSH_EXIT_STATUS -ne 0 ]]
                            then
                                EXIT_STATUS=$SSH_EXIT_STATUS
                                log 'Error in Stopping the instance....'
                        fi
                else
                    write "${BC_YELLOW}\n $INSTANCE_ID --> ($NAME_TAG) ${NC} already stopped. Skipping to next..."
      fi

                #cleanup of temp file
                done < ~/AWS.txt
                rm -f ~/AWS.txt
                log 'All of your AWS instances stopped'
fi
}
setup(){
 if [[ "$NUM_ARG" -ge 3 ]]
    then
        log "Invalid number of arguments !!"
        usage
    elif [[ "$NUM_ARG" -le 1 ]]
        then
            log 'Please provide the owner tag for your AWS instance'
            usage
         else
             log 'Finding your AWS instances....'
             OWNER=$ARG
             INSTANCE_FOUND=$(aws --output text ec2 describe-instances --filters "Name=tag:owner,Values=$OWNER")
             if [[ -z "${INSTANCE_FOUND// }" ]]
                then
                    log 'No AWS instances found with supplied OWNER tag. Please verify the tag'
                else
                    NUM_INSTANCES=$(aws --output json ec2 describe-instances --filters "Name=tag:owner,Values=$OWNER" | grep "PrivateIpAddress" | awk '{print $2}' | tr -d "\"" | tr -d "," | tr -d "[" | sort | uniq | sed '/^\s*$/d' | wc -l)
                    aws --output json ec2 describe-instances --filters "Name=tag:owner,Values=$OWNER" |grep "PrivateDnsName" | awk '{print $2}' | sort | uniq | tr -d "\"" | tr -d "," > ~/AWS.txt
                    while read line
                        do
                            HOSTNAME=$line
                            HOST_IP=$(echo  ${HOSTNAME%%.*} | sed -e 's/ip-//' -e 's/-/./g')
                            NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$HOSTNAME" | grep TAGS | grep -i name | awk '{print $3}')
                            HOST_IN_ETC=$(grep $HOSTNAME $HostFile)

                            if [[  -z "${HOST_IN_ETC// }" ]]
                                then
                                    sudo bash -c "echo  $HOST_IP  $HOSTNAME $NAME_TAG >> /etc/hosts"
                                    write "${BC_YELLOW}\n [$HOST_IP]  [$HOSTNAME] [$NAME_TAG] ${NC} added to the /etc/hosts file"
                                else
                                    write "${BC_YELLOW}\n $HOSTNAME ${NC} alreasy exists in /etc/hosts file. skipping..."

                            fi
                    #cleanup of temp file
                    done < ~/AWS.txt
                    rm -f ~/AWS.txt
             fi

  fi
}
reaper()
{
  if [[ "$NUM_ARG" -gt 1 ]]
    then
        log "Invalid number of arguments !!"
        usage
    elif [[ "$NUM_ARG" -eq 1 ]]
        then
            aws --output json ec2 describe-instances --filters "Name=tag:aws-reaper,Values=on" | grep "PrivateDnsName" | awk '{print $2}' | sort | uniq | tr -d "\"" | tr -d "," > ~/AWS.txt
            while read line
                do
                    AWS_HOSTNAME=$line
                    INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
                    NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" | grep TAGS | grep -i name | awk '{print $3}')
                    STATUS=$(aws --output text ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
                    if [[ "$STATUS" == running ]]
                        then
                            write   "Stopping ${BC_YELLOW}\n $INSTANCE_ID --> ($NAME_TAG)... ${NC}"
                            aws ec2 stop-instances --instance-ids $INSTANCE_ID
                            SSH_EXIT_STATUS=$?
                            if [[ $SSH_EXIT_STATUS -ne 0 ]]
                                then
                                    EXIT_STATUS=$SSH_EXIT_STATUS
                                    log 'Error in Stopping the instance....'
                            fi
                    else
                        write "${BC_YELLOW}\n $INSTANCE_ID --> ($NAME_TAG) ${NC} already stopped. Skipping to next..."
                    fi


            done < ~/AWS.txt

            rm -f ~/AWS.txt
            log 'AWS instances with aws-reaper tag set to ON are now stopped'
  fi
}
tag(){
  if [[ "$NUM_ARG" -ge 4 ]]
    then
        log "Invalid number of arguments !!"
        usage
    elif [[ "$NUM_ARG" -eq 1 ]]
        then
            write  "Querying tags on you AWS instances...."
            write "${BC_YELLOW}\nOWNER\t\t\t\t\t\tNAME\t\t\t\t\t\tAUTOSTOP\t\t\t\t\t\tREAPER${NC}"
            for i in $(aws --output json ec2 describe-instances --filters "Name=tag:owner,Values=$USERNAME" | grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",");
                do
                    OWNER=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "owner" | awk '{ print $3 }')
                    AUTOSTOP=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "autostop" | awk '{ print $3 }')
                    REAPER=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "aws-reaper" | awk '{ print $3 }')
                    NAME=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "name" | awk '{ print $3 }')
                    write  "$OWNER\t\t\t\t\t\t$NAME\t\t\t\t\t\t$AUTOSTOP\t\t\t\t\t\t$REAPER"
                done
         elif [[ "$NUM_ARG" -eq 2 ]]
         then
            if [[ "$ARG" == all ]]
                then
                    write  "Querying tags on all AWS instances...."
                    write "${BC_YELLOW}\nOWNER\t\t\t\t\t\tNAME\t\t\t\t\t\tAUTOSTOP\t\t\t\t\t\tREAPER${NC}"
                    for i in $(aws --output json ec2 describe-instances --filters "Name=tag:dept,Values=support" | grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",");
                        do
                            OWNER=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "owner" | awk '{ print $3 }')
                            AUTOSTOP=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "autostop" | awk '{ print $3 }')
                            REAPER=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "aws-reaper" | awk '{ print $3 }')
                            NAME=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "name" | awk '{ print $3 }')
                        write  "$OWNER\t\t\t\t\t\t$NAME\t\t\t\t\t\t$AUTOSTOP\t\t\t\t\t\t$REAPER"
                        done
                else
                    write  "Querying tags on your AWS instances...."
                    HOSTNAME=$ARG
                    AWS_HOSTNAME=$(cat /etc/hosts | grep -w $HOSTNAME |  awk '{print $2}')
                    INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
                    if [[ -z "${AWS_HOSTNAME// }" ]]
                        then
                            log 'Host not found in /etc/hosts file. Please verify the hostname'
                        elif [[ -z "${INSTANCE_ID// }" ]]
                            then
                                log 'AWS instance not found !!'
                        else
                            write "${BC_YELLOW}\nOWNER\t\t\t\t\t\tNAME\t\t\t\t\t\tAUTOSTOP\t\t\t\t\t\tREAPER${NC}"
                        for i in $(aws --output json ec2 describe-instances --filters "Name=tag:name,Values=$HOSTNAME" | grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",");
                            do
                                OWNER=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "owner" | awk '{ print $3 }')
                                AUTOSTOP=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "autostop" | awk '{ print $3 }')
                                REAPER=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "aws-reaper" | awk '{ print $3 }')
                                NAME=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "name" | awk '{ print $3 }')
                                write  "$OWNER\t\t\t\t\t\t$NAME\t\t\t\t\t\t$AUTOSTOP\t\t\t\t\t\t$REAPER"
                            done
                    fi
             fi
          elif [[ "$NUM_ARG" -eq 3 ]]
                then
                    write  "Setting aws-reaper tag on your AWS instances...."
                    HOSTNAME=$ARG
                    AWS_HOSTNAME=$(cat /etc/hosts | grep -w $HOSTNAME |  awk '{print $2}')
                    INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
                    if [[ -z "${AWS_HOSTNAME// }" ]]
                        then
                            log 'Host not found in /etc/hosts file. Please verify the hostname'
                        elif [[ -z "${INSTANCE_ID// }" ]]
                            then
                                log 'AWS instance not found !!'
                        elif [[ "$ARG1" == on || "$ARG1" == off ]];
                            then
                                aws ec2 create-tags --resources $INSTANCE_ID --tags Key="aws-reaper",Value=$ARG1
                                write  "aws-reaper tag added to your AWS instance."

                            else
                                log 'aws-reaper tag value can be either ON or OFF'
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
     'reaper')
        # stop the instances with aws-reaper tag ON
        reaper
       ;;
     'tag')
        # Add aws-reaper tag to AWS instances
        tag
       ;;
  #prints command usage in case of bad arguments
    *) usage
      ;;
esac
exit $EXIT_STATUS
