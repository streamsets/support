<img src="/images/readme.png" align="right" />

#### <aws.sh> This script perform following operations on your EC2 instance
1) Status check
2) Start/Stop instance
3) Add tags to the instances
4) Update /etc/hosts file with your EC2 instance information. 
   Use the 'setup' option to update your hosts file with your current ec2 instances

#### Pre-req:

1) Get your AWS Access ID and Secret from IT
2) Install awscli (eg: for OSX -brew install awscli) or follow ==> https://docs.aws.amazon.com/cli/latest/userguide/cli-install-macos.html

#### Configuring your AWS CLI
  Run the command 'aws configure'
  This will ask you for following:
  
AWS Access Key ID: get from IT 

AWS Secret Access Key: get from IT

Default region name: Region for your EC2 instances. For example:  [us-west-2] - ** Please note that the region is 'us-west-2' NOT 'us-west-2a'

Default output format:  [json / text] ** Script can handle either, however choose JSON for a better format if you are going to play with AWS CLI

3) This scripts makes certain assumptions and need one customization

#### Please note:

1) The 'owner' tag on your Ec2 instance is same as your user name on your Mac.
   If not hard-code the USERNAME at the top of the script.
2) When you clone this script locally, please update the 'SSH_KEY'variable at the top with your AWS key
3) You can add docker start command to your ~/.bash_profile on the ec2 instance to launch your docker containers upon starting the instance using this script 

      
#### (Optional)Setting up a cron job:

** This script is running as a cronjob on the 'Unbundle' server for the whole team, so individuals don't need to setup the cron job.

1) vi jobname.cron
2) Specify the schedule and the script to run.

  For example:
  05 07 * * *  /home/ec2-user/aws.sh stop lab
  
  Above means that the script will be called every day at 7:05 AM 
  
3) To schedule the job, run ==> sudo crontab -u ec2-user jobname.cron

4) To list your cron job, run ==> sudo crontab -u ec2-user -l

5) If you need to make changes to your job, run ==> sudo crontab -u ec2-user -e

6) To remove the cron job, run ==> sudo crontab -u ec2-user -r
  
*****************************************************************************************************************************************************************
#### <doc.sh>: This scripts makes it easy to start/stop/status-check on the Docker engine on your Mac

*****************************************************************************************************************************************************************
#### <longPause.sh>: This scripts helps to spot a timeline gap in a given log file

*****************************************************************************************************************************************************************
#### <threads.sh>: This scripts collects java thread dumps 

*****************************************************************************************************************************************************************
#### <startPipeline.sh>: Example script to launch pipeline from CLI

*****************************************************************************************************************************************************************
#### <SyncRunInfo.pl>: 

                    Perl script to delete the extra directories which may be found in $SDC_DATA/runInfo
                    These directories are sometimes left over when pipelines are deleted and some error
                    occurs which leaves these directories in place. 
                    
                    This script gathers all the directories in the $SDC_DATA/pipelines directory and
                    the $SDC_DATA/runInfo directory, figures out which directories are in runInfo without a
                    corresponding entry in pipleines, and deletes the extra runInfo directories.
                    
                    Also, the actual deleteing part is commented out, so you can try it and determine
                    if it meets your requirements. 

*****************************************************************************************************************************************************************                  
#### <on-prem.sh>: This script make it easy to install the SCH/controlhub with all the basic requirement


 Need to create new instance with centos7 or Amazon Linux 2 
 Download the script on the newly created instance and please make it executable using below command

 Usage : chmod +x on-prem-sch.sh

 Execute the script using below command and it'll ask for SCH version and for SSL , Please select according to the requirement 

 Usage : sh -x on-prem-sch.sh
