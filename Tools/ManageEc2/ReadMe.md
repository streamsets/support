<img src="/images/readme.png" align="right" />

This script perform following operations on your EC2 instance
1) Status check
2) Start instance
3) Stop instance
4) Update /etc/hosts file with your EC2 instance information

# Pre-req:

1) Get your AWS Access ID and Secret from IT
2) Install awscli (eg: for OSX -brew install awscli) or follow ==> https://docs.aws.amazon.com/cli/latest/userguide/cli-install-macos.html

** You can add docker start command to your ~/.bash_profile on the ec2 instance to launch your docker containers upon starting the instance using this script 

# Usage: /Users/sanjeev/aws.sh [-start] [-stop] [-status] [-setup]

  -start  <instance-name>       Start the AWS instance.
  
  -stop    <instance-name>     Stop the AWS instance
  
  -status   [OPTIONAL] <instance-name>    Status of the AWS instance
  
  -setup <your-name>  Update /etc/hosts file with your EC2 instances
  
      ** <your-name>  == Owner TAG on your EC2 instances
      
