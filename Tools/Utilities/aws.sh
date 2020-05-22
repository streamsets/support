#!/bin/bash

USERNAME=$USER  # Hard code this value for status command to work if running the script from a host where username will be different from your username
HostFile='/etc/hosts'

# Comment out if not using zsh
#To install zsh on mac, run --> brew install zsh

BYellow='\033[1;33m' # Foreground BYellow
On_Yellow='\033[33;5;7m' #Backgroud BYellow
Color_Off='\033[0m' # No Color


#prints command usage
usage() {
        printf   "\n  Usage: ./aws.sh ${On_Yellow}  [start] [stop] [stopAll] [status] [reaper] [tag] [setup]   ${Color_Off} "  >&2
        printf   "\n${On_Yellow}\n start  <instance-name>${Color_Off}                                  Start the AWS instance."  >&2
        printf   "\n${On_Yellow}\n stop    <instance-name>${Color_Off}                                 Stop the AWS instance"  >&2
        printf   "\n${On_Yellow}\n stopAll   ${Color_Off}                                              Stop all of your AWS instances"  >&2
        printf   "\n${On_Yellow}\n status   [OPTIONAL] <instance-name>${Color_Off}                     Status of the AWS instance"  >&2
        printf   "\n${On_Yellow}\n reaper ${Color_Off}                                                 Stop the instances with reaper tag ON"  >&2
        printf   "\n${On_Yellow}\n tag [OPTIONAL] <instance-name> [OPTIONAL] <tag=value>${Color_Off}   Add/update tags(autostop/reaper) to the AWS instances"  >&2
        printf   "\n${On_Yellow}\n setup <AWS-OWNER-TAG>${Color_Off}                                   Updates the /etc/hosts file with your AWS instances"  >&2
        printf   "\n                                                         <your-name>  == OWNER tag on your AWS instances \n"  >&2
}

log() {
    printf "\n ${BYellow}$1${Color_Off} \n"
}
logger() {
    printf "\n[$(date)]-- $1 \n"
}
write() {
   printf "$1 \n"
}

NUM_ARG=$#
ARG=$2  #command
ARG1=$3 #instance-name / zone / owner etc

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
                    echo  "$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep name | awk '{print $3 "        ==> "}' | tr -d '\n')$(aws --output text ec2 describe-instances --instance-id $i | grep -w STATE | awk '{print $3}')"
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
                    NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" | grep TAGS | grep name | awk '{print $3}')
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
      NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" | grep TAGS | grep name | awk '{print $3}')      STATUS=$(aws --output text ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
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
                    write "\nStarting: ${On_Yellow} $INSTANCE_ID --> ($NAME_TAG) ${Color_Off}"
                    aws ec2 start-instances --instance-ids $INSTANCE_ID
                    SSH_EXIT_STATUS=$?
                    if [[ $SSH_EXIT_STATUS -ne 0 ]]
                        then
                            EXIT_STATUS=$SSH_EXIT_STATUS
                            log 'Error in starting the instance....'
                        else
                            sleep 10
                            write "${On_Yellow}\n $INSTANCE_ID --> ($NAME_TAG) ${Color_Off} started successfully !!"
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
      NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" | grep TAGS | grep name | awk '{print $3}')
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
                    write "\nStopping: ${On_Yellow} $INSTANCE_ID --> ($NAME_TAG) ${Color_Off}"
                    aws ec2 stop-instances --instance-ids $INSTANCE_ID
                    SSH_EXIT_STATUS=$?
                    if [[ $SSH_EXIT_STATUS -ne 0 ]]
                        then
                            EXIT_STATUS=$SSH_EXIT_STATUS
                            log 'Error in stopping the instance....'
                        else
                            sleep 10
                            write "${On_Yellow}\n $INSTANCE_ID --> ($NAME_TAG) ${Color_Off} stopped successfully !!"
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
                NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" | grep TAGS | grep name | awk '{print $3}')
                STATUS=$(aws --output text ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
                if [[ $STATUS == 'running' ]]
                    then
                        write "Stopping ${On_Yellow}\n $INSTANCE_ID --> ($NAME_TAG)... ${Color_Off}"
                        aws ec2 stop-instances --instance-ids $INSTANCE_ID
                        SSH_EXIT_STATUS=$?
                        if [[ $SSH_EXIT_STATUS -ne 0 ]]
                            then
                                EXIT_STATUS=$SSH_EXIT_STATUS
                                log 'Error in Stopping the instance....'
                        fi
                else
                    write "${On_Yellow}\n $INSTANCE_ID --> ($NAME_TAG) ${Color_Off} already stopped. Skipping to next..."
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
                            NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$HOSTNAME" | grep TAGS | grep name | awk '{print $3}')
                            HOST_IN_ETC=$(grep $HOSTNAME $HostFile)

                            if [[  -z "${HOST_IN_ETC// }" ]]
                                then
                                    sudo bash -c "echo  $HOST_IP  $HOSTNAME $NAME_TAG >> /etc/hosts"
                                    write "${On_Yellow}\n [$HOST_IP]  [$HOSTNAME] [$NAME_TAG] ${Color_Off} added to the /etc/hosts file"
                                else
                                    write "${On_Yellow}\n $HOSTNAME ${Color_Off} alreasy exists in /etc/hosts file. skipping..."

                            fi
                    #cleanup of temp file
                    done < ~/AWS.txt
                    rm -f ~/AWS.txt
             fi

  fi
}
reaper()
{
  if [[ "$NUM_ARG" -gt 2 ]]
    then
        log "Invalid number of arguments !!"
        usage
    elif [[ "$NUM_ARG" -eq 2 ]]
        then
            aws --output json ec2 describe-instances --filters "Name=tag:reaper,Values=on,Name=tag:zone,Values=$ARG" | grep "PrivateDnsName" | awk '{print $2}' | sort | uniq | tr -d "\"" | tr -d "," > ~/AWS.txt
            while read line
                do
                    AWS_HOSTNAME=$line
                    INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
                    NAME_TAG=$(aws --output text ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" | grep TAGS | grep name | awk '{print $3}')
                    STATUS=$(aws --output text ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
                    if [[ "$STATUS" == running ]]
                        then
                            logger   "Stopping $INSTANCE_ID --> ($NAME_TAG)..."
                            aws ec2 stop-instances --instance-ids $INSTANCE_ID
                            SSH_EXIT_STATUS=$?
                            if [[ $SSH_EXIT_STATUS -ne 0 ]]
                                then
                                    EXIT_STATUS=$SSH_EXIT_STATUS
                                    logger "Error in Stopping the instance...."
                            fi
                    else
                        logger "$INSTANCE_ID --> ($NAME_TAG) already stopped. Skipping to next..."
                    fi


            done < ~/AWS.txt

            rm -f ~/AWS.txt
            logger "AWS instances with reaper tag set to ON are now stopped"
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
            write "${On_Yellow}\nOWNER\t\t\t\t\t\tNAME\t\t\t\t\t\tAUTOSTOP\t\t\t\t\t\tREAPER${Color_Off}"
            for i in $(aws --output json ec2 describe-instances --filters "Name=tag:owner,Values=$USERNAME" | grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",");
                do
                    OWNER=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "owner" | awk '{ print $3 }')
                    AUTOSTOP=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "autostop" | awk '{ print $3 }')
                    REAPER=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "reaper" | awk '{ print $3 }')
                    NAME=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep  "name" | awk '{ print $3 }')
                    ZONE=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep  "zone" | awk '{ print $3 }  ');
                    if [ -z "$OWNER" ]; then OWNER="<empty>"; fi;
                    if [ -z "$AUTOSTOP" ]; then AUTOSTOP="<empty>"; fi;
                    if [ -z "$REAPER" ]; then REAPER="<empty>"; fi;
                    if [ -z "$NAME" ]; then NAME="<empty>"; fi;
                    if [ -z "$ZONE" ]; then ZONE="<empty>"; fi;
                    write  "$OWNER\t\t\t\t\t\t$NAME\t\t\t\t\t\t$AUTOSTOP\t\t\t\t\t\t$REAPER"
                done
         elif [[ "$NUM_ARG" -eq 2 ]]
         then
            if [[ "$ARG" == all ]]
                then
                    write  "Querying tags on all AWS instances...."
                    write "${On_Yellow}\nOWNER\t\t\t\t\t\tNAME\t\t\t\t\t\tAUTOSTOP\t\t\t\t\t\tREAPER${Color_Off}"
                    for i in $(aws --output json ec2 describe-instances --filters "Name=tag:dept,Values=support" | grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",");
                        do
                            OWNER=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "owner" | awk '{ print $3 }')
                            AUTOSTOP=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "autostop" | awk '{ print $3 }')
                            REAPER=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "reaper" | awk '{ print $3 }')
                            NAME=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep  "name" | awk '{ print $3 }')
                            ZONE=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep  "zone" | awk '{ print $3 }  ');
                            if [ -z "$OWNER" ]; then OWNER="<empty>"; fi;
                            if [ -z "$AUTOSTOP" ]; then AUTOSTOP="<empty>"; fi;
                            if [ -z "$REAPER" ]; then REAPER="<empty>"; fi;
                            if [ -z "$NAME" ]; then NAME="<empty>"; fi;
                            if [ -z "$ZONE" ]; then ZONE="<empty>"; fi;
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
                            write "${On_Yellow}\nOWNER\t\t\t\t\t\tNAME\t\t\t\t\t\tAUTOSTOP\t\t\t\t\t\tREAPER${Color_Off}"
                        for i in $(aws --output json ec2 describe-instances --filters "Name=tag:name,Values=$HOSTNAME" | grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",");
                            do
                                OWNER=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "owner" | awk '{ print $3 }')
                                AUTOSTOP=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "autostop" | awk '{ print $3 }')
                                REAPER=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep -i "reaper" | awk '{ print $3 }')
                                NAME=$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep  "name" | awk '{ print $3 }')
                                write  "$OWNER\t\t\t\t\t\t$NAME\t\t\t\t\t\t$AUTOSTOP\t\t\t\t\t\t$REAPER"
                            done
                    fi
             fi
          elif [[ "$NUM_ARG" -eq 3 ]]
                then

                    TAG=$(echo $ARG1 | cut -d'=' -f1)
                    VALUE=$(echo $ARG1 | cut -d'=' -f2)
                    HOSTNAME=$ARG
                    AWS_HOSTNAME=$(cat /etc/hosts | grep -w $HOSTNAME |  awk '{print $2}')
                    INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
                    if [[ -z "${AWS_HOSTNAME// }" ]]
                        then
                            log 'Host not found in /etc/hosts file. Please verify the hostname'
                        elif [[ -z "${INSTANCE_ID// }" ]]
                            then
                                log 'AWS instance not found !!'
                            elif [[ ! $TAG =~ ^(autostop|reaper|zone)$ ]];
                                then
                                    log "Invalid TAG <$TAG> !!"
                                    write 'Please choose either: [ autostop | reaper | zone ]'
                                    write 'For example: ./aws.sh tag <instance-name> autostop=off'
                                #elif [[ "$TAG" == autostop || "$TAG" == reaper ]] && [[ "$VALUE" == on || "$VALUE" == off ]];
                                elif [[ $TAG =~ (autostop|reaper)$ ]] && [[ $VALUE =~ (on|off)$ ]];
                                    then
                                        write  "Setting requested tag on your AWS instances...."
                                        aws ec2 create-tags --resources $INSTANCE_ID --tags Key=$TAG,Value=$VALUE
                                        SSH_EXIT_STATUS=$?
                                        if [[ $SSH_EXIT_STATUS -ne 0 ]]
                                            then
                                                EXIT_STATUS=$SSH_EXIT_STATUS
                                                log 'Error in adding the requested tag'
                                            else
                                                write  "Requested tag added to your AWS instance."
                                        fi
                                elif [[ $TAG =~ (autostop|reaper)$ ]] && [[ ! $VALUE =~ ^(on|off)$ ]];
                                    then
                                        log 'The value for the tag can be [ ON/OFF ]'
                                        write 'For example: ./aws.sh tag <instance-name> autostop=off"'
                                elif [[ $TAG =~ (zone)$ ]] && [[ $VALUE =~ (US|EMEA|APAC)$ ]];
                                     then
                                         write  "Setting requested tag on your AWS instances...."
                                         aws ec2 create-tags --resources $INSTANCE_ID --tags Key=$TAG,Value=$VALUE
                                         SSH_EXIT_STATUS=$?
                                         if [[ $SSH_EXIT_STATUS -ne 0 ]]
                                            then
                                                EXIT_STATUS=$SSH_EXIT_STATUS
                                                log 'Error in adding the requested tag'
                                            else
                                                write  "Requested tag added to your AWS instance."
                                         fi
                                elif [[ $TAG =~ (zone)$ ]] && [[ ! $VALUE =~ ^(US|EMEA|APAC)$  ]];
                                    then
                                        log 'The value for the tag should be [ US | EMEA | APAC ]'
                                        write 'For example: ./aws.sh tag <instance-name> zone=US'

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
        # stop the instances with reaper tag ON
        reaper
       ;;
     'tag')
        # Add reaper tag to AWS instances
        tag
       ;;
        #prints command usage in case of bad arguments
     *) usage
      ;;
esac
#exit $EXIT_STATUS
