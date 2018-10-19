<img src="/images/readme.png" align="right" />

# This script perform following operations on your EC2 instance
1) Status check
2) Start instance
3) Stop instance
4) Update /etc/hosts file with your EC2 instance information. Use 'setup' option to update your hosts file with your current ec2 instances

# Pre-req:

1) Get your AWS Access ID and Secret from IT
2) Install awscli (eg: for OSX -brew install awscli) or follow ==> https://docs.aws.amazon.com/cli/latest/userguide/cli-install-macos.html

  # Configuring your AWS CLI
  Run the command 'aws configure'
  This will ask you for following:
  
AWS Access Key ID: get from IT 
AWS Secret Access Key: get from IT
Default region name: Region for your EC2 instances. For example:  [us-west-2] - ** Please note that the region is 'us-west-2' NOT 'us-west-2a'
Default output format:  [json / text] ** Script can handle either, however choose JSON for a better format if you are going to play with AWS CLI

3) This scripts makes certain assumptions and need one customization

# Assumptions: 
1) The 'owner' tag on your Ec2 instance is same as your user name on your Mac
2) Your host file is default /etc/hosts ** I'll wonder why it would be anything else ;)

# Customization:
1) When you clone this script locally, please update the 'SSH_KEY'variable at the top with your AWS key

# Pro-Tip: 

You can add docker start command to your ~/.bash_profile on the ec2 instance to launch your docker containers upon starting the instance using this script 

# Usage: /Users/sanjeev/aws.sh [-start] [-stop] [-status] [-setup]

  -start  <instance-name>       Start the AWS instance.
  
  -stop    <instance-name>     Stop the AWS instance
  
  -status   [OPTIONAL] <instance-name>    Status of the AWS instance
  
  -setup <your-name>  Update /etc/hosts file with your EC2 instances
  
      ** <your-name>  == Owner TAG on your EC2 instances
      
# Coming soon:

I'm going to test setting up cron job using this script so that we can shutdown our instance right after they are automatically restarted by IT
# why?
Becasue now you can leverage this script to manage your instances from your Mac and therefore no need for these instances to start running at 7 AM in the morning when you're not using it. You're welcome ;)
