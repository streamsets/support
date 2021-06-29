#!/bin/bash
cr=`echo $'\n>'`
read -p "SCH username: $cr" username
read -sp "SCH password: $cr" password
echo
read -p "SCH label: $cr" label
echo
echo "Thank you $username, let's build the image and regitster SDC to SCH"
echo
docker build -t registered/sdc .
sleep 20
docker run  --restart on-failure -p 18630:18630 -d --name registered-sdc registered/sdc
sleep 20
docker exec registered-sdc /opt/streamsets-datacollector-4.0.0/bin/streamsets cli -U  https://localhost:18630 -D https://cloud.streamsets.com system enableDPM --dpmUrl https://cloud.streamsets.com --dpmUser "$username" --dpmPassword "$password" --labels $label
curl --insecure -u admin:admin -X POST https://localhost:18630/rest/v1/system/restart -H "X-Requested-By:sdc"
