  #!/bin/bash
# This script start/stop/status-check the AWS instances.

SSH_KEY='~/.ssh/sanju_aws.pem'
USERNAME=$USER
HostFile='/etc/hosts'
#prints command usage
usage() {
  echo "Usage: ${0} [-start] [-stop] [-status] [-setup] \n" >&2
  echo '  -start  <instance-name>       Start the AWS instance.' >&2
  echo '  -stop    <instance-name>     Stop the AWS instance' >&2
  echo '  -status   [OPTIONAL] <instance-name>    Status of the AWS instance' >&2
  echo '  -setup <your-name>  Update /etc/hosts file with your EC2 instances' >&2
  echo '      ** <your-name>  == Owner TAG on your EC2 instances \n' >&2
  exit 1
}
log() {
  echo "\033[33;5;7m\n $1 \n\033[0m"
}
if [[ $# -gt 2 ]]
  then
    log 'Invalid arguments !!'
    usage
    exit 1
fi

case "$1" in
  #start the ec2 instance
	'start')
          if [[ $2 < 1 ]]
            then
              log 'Please provide instance name'
              usage
              exit 1
          fi
         HOSTNAME=$2
         AWS_HOSTNAME=$(cat /etc/hosts | grep -i $HOSTNAME |  awk '{print $2}')
         if [[ -z "${AWS_HOSTNAME// }" ]]
            then
              log 'Host not found in /etc/hosts file. Please verify the hostname'
              exit 1
         fi
         INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
         echo "\nStarting InstanceID: \033[33;5;7m $INSTANCE_ID \033[0m"
  		   aws ec2 start-instances --instance-ids $INSTANCE_ID
  		   SSH_EXIT_STATUS=$?
  		   if [[ $SSH_EXIT_STATUS -ne 0 ]]
			      then
				          EXIT_STATUS=$SSH_EXIT_STATUS
                      log 'Error in starting the instnace....'
                    else
                      sleep 10
                      echo "\033[33;5;7m\n $AWS_HOSTNAME \033[0m started successfully !!"
                      echo "Please login to your instance. ex: ssh -i $SSH_KEY ubuntu@$AWS_HOSTNAME\n"
                    fi
  		   ;;
  #stop the ec2 instance
  'stop')

          if [[ $2 < 1 ]]
            then
              log 'Please provide name of the instance to stop'
              usage
              exit 1
          elif  [[ $2 > 1 ]]
            then
              HOSTNAME=$2
              AWS_HOSTNAME=$(cat /etc/hosts | grep -i $HOSTNAME |  awk '{print $2}')
              if [[ -z "${AWS_HOSTNAME// }" ]]
                 then
                   log 'Host not found in /etc/hosts file. Please verify the hostname'
                   exit 1
              fi
              echo "Stopping your <$2> instance...."
              INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
	            aws ec2 stop-instances --instance-ids $INSTANCE_ID
	            SSH_EXIT_STATUS=$?
  		          if [[ $SSH_EXIT_STATUS -ne 0 ]]
			             then
				                 EXIT_STATUS=$SSH_EXIT_STATUS
				                 log 'Error in Stopping the instnace....'
                fi
          fi
	      ;;
  #Query the status on the ec2 instance
	'status')
            # Query STATUS
            if [[ $2 < 1 ]]
            then
              echo "Querying status on all of your EC2 instances...."
             for i in $(aws --output json ec2 describe-instances --filters "Name=tag:owner,Values=$USERNAME" | grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",");
             do
                echo "$(aws --output text ec2 describe-instances --instance-id $i | grep TAGS | grep name | awk '{print $3 "        ==> "}' | tr -d '\n')$(aws --output text ec2 describe-instances --instance-id $i | grep -w STATE | awk '{print $3}')"
             done
           elif [[ $2 > 1 ]]
               then
                 HOSTNAME=$2
                 AWS_HOSTNAME=$(cat /etc/hosts | grep -i $HOSTNAME |  awk '{print $2}')
                 if [[ -z "${AWS_HOSTNAME// }" ]]
                    then
                      log 'Host not found in /etc/hosts file. Please verify the hostname'
                      exit 1
                 fi
                 echo "Querying status of <$2> instances...."
                 INSTANCE_ID=$(aws --output json ec2 describe-instances --filters "Name=private-dns-name,Values=$AWS_HOSTNAME" |grep "InstanceId" | awk '{print $2}' | tr -d "\"" | tr -d ",")
                 STATUS=$(aws ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
                  if [[ $STATUS = 'running' ]]
                  then
     		             echo "Instance is $STATUS"
                  else
                      log 'Instance is not running'
     	              fi
             fi
        ;;

    'setup')
              echo "\nFinding your EC2 instances...."
              if [[ $2 < 1 ]]
                then
                  log 'Please provide the owner tag for your EC2 instance'
                  usage
                  exit 1
              fi
              if  [[ $2 > 1 ]]
                then
                  OWNER=$2
                  INSTANCE_FOUND=$(aws --output text ec2 describe-instances --filters "Name=tag:owner,Values=$OWNER")
                    if [[ -z "${INSTANCE_FOUND// }" ]]
                      then
                       log 'No EC2 instances found with supplied owner tag. Please verify the tag'
                       exit 1
                     else
                       NUM_INSTANCES=$(aws --output json ec2 describe-instances --filters "Name=tag:owner,Values=$OWNER" | grep "PrivateIpAddress" | awk '{print $2}' | tr -d "\"" | tr -d "," | tr -d "[" | sort | uniq | sed '/^\s*$/d' | wc -l)
                       aws --output json ec2 describe-instances --filters "Name=tag:owner,Values=$OWNER" |grep "PrivateDnsName" | awk '{print $2}' | sort | uniq | tr -d "\"" | tr -d "," > ~/AWS.txt
                       while read line
                        do
                          hostname=$line
                          hostip=$(echo ${hostname%%.*} | sed -e 's/ip-//' -e 's/-/./g')
                          if [[ 'grep $hostname $HostFile' ]]
                          then
                            echo "\033[33;5;7m\n $hostname \033[0m alreasy exists in /etc/hosts file. skipping..."
                          else
                            sudo bash -c "echo $hostip  $hostname >> /etc/hosts"
                          fi
                       done < AWS.txt
                       rm -f AWS.txt
                    fi
              fi

       ;;

  #prints command usage in case of bad arguments
    *) usage
      ;;
esac
exit $EXIT_STATUS
