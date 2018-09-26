<img src="/images/readme.png" align="right" />

This script start/stop the AWS instance.

# Pre-req:

1) Get your AWS Access ID and Secret from IT
2) Install awscli (eg: for OSX -brew install awscli)
3) Add docker start command to your .bash_profile on the ec2 instance to launch your docker containers upon starting the instance using this script 

# Usage: /Users/sanjeev/ec2.sh [-start] [-stop] [-status]

This script start/stop the AWS instance
  -start         Start the AWS instance.
  -stop         Stop the AWS instance
  -status         Status of the AWS instance
