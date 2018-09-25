  #!/bin/bash
# This script start/stop the AWS instance.

# Pre-req:
#1) Get your AWS Access ID and Secret from IT
#2) Install awscli (eg: for OSX -brew install awscli)
#3) Add docker start command to your .bash_profile on the ec2 instance to launch your docker containers upon starting the instance using this script 

AWS_HOST='<ec2 FQDN>'
INSTANCE_ID='<ec2 instance ID>'
SSH_KEY='<your SSH key>'
#prints command usage
usage() {
  echo "Usage: ${0} [-start] [-stop] [-status]" >&2
  echo 'This script start/stop the AWS instance' >&2
  echo '  -start         Start the AWS instance.' >&2
  echo '  -stop         Stop the AWS instance' >&2
  echo '  -status         Status of the AWS instance' >&2
  exit 1
}

case "$1" in
  #start the ec2 instance
	'start') echo "Starting your EC2 instance......."
  		   aws ec2 start-instances --instance-ids $INSTANCE_ID
  		   SSH_EXIT_STATUS=$?
  		   if [[ $SSH_EXIT_STATUS -ne 0 ]]
			      then
				          EXIT_STATUS=$SSH_EXIT_STATUS
				              log 'Error in starting the instnace....'
                    else
                      sleep 20
                      ssh -i $SSH_KEY ubuntu@$AWS_HOST
                    fi
  		   ;;
  #stop the ec2 instance
  'stop') echo "Stopping your EC2 instance......."
	      aws ec2 stop-instances --instance-ids $INSTANCE_ID
	      SSH_EXIT_STATUS=$?
  		   if [[ $SSH_EXIT_STATUS -ne 0 ]]
			      then
				          EXIT_STATUS=$SSH_EXIT_STATUS
				              log 'Error in Stopping the instnace....'
                    fi
	      ;;
  #Query the status on the ec2 instance
	'status')  echo "Querying status on your EC2 instance......."
             STATUS=$(aws ec2 describe-instance-status --instance-ids $INSTANCE_ID | sed -n '2p' |  awk '{print $3}')
             if [[ $STATUS = 'running' ]]
             then
		             echo "Instance is $STATUS"
             else
                 echo "Instance is not running"
	              fi
        ;;
  #prints command usage in case of bad arguments
       *) usage
          ;;
esac
exit $EXIT_STATUS
