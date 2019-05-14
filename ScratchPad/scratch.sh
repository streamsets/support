#!/usr/bin/env bash

=============================================================== Development Notes =================================================================
 # Create a new branch with the Jira id
 git checkout -b SDC-11465 origin/master
 git status
 #Make changes and commit

 git add <files>
 git commit

 # Verify the changes can be seen in the got log
 git log

 # Fetach changes by others and rebase

 git fetch
 git rebase -i
 #Send for review:

 git review -R


Enable remote debugger:
export SDC_JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=51598

=============================================================== BASH =================================================================
Python install on mac: https://wsvincent.com/install-python3-mac/

TCPDUMP:
tcpdump -A -nn dst 172.18.4.115 port 8080 

Automated jstack - https://github.com/Azure/hbase-utils/blob/master/debug/hdi_collect_stacks.sh


CURL:

curl -i --negotiate -u : "http://master2.openstacklocal:50070/webhdfs/v1/tmp/?op=LISTSTATUS"

keytool -genkey -keyalg RSA -alias selfsigned -keystore keystore1.jks -storepass password -validity 360 -keysize 2048



sudo lsof -i -n | grep LISTEN | grep java > lsof-`hostname -i`.txt

Find class in JAR:

find ./ | grep jar$ | while read fname; do jar tf $fname | grep JmxReporter && echo $fname; done
sed -i 's/something/other/g' filename.txt


Add a service user:
for f in `cat hosts.txt | awk '{print $1}'`; do ssh -i ~/.ssh/sanju.pem root@$f useradd -g hdfs sanju ; done
Distribute host file:
for f in `cat hosts.txt | awk '{print $1}'`; do scp -i ~/.ssh/sanju.pem ~/Documents/hosts root@$f:/etc/ ; done

Kerberos Setup⇒
yum -y install krb5-server krb5-libs krb5-workstation
vi /etc/krb5.conf
kdb5_util create -s
/etc/init.d/krb5kdc start krb5kdc
/etc/init.d/kadmin start
chkconfig krb5kdc on
chkconfig kadmin on
kadmin.local -q "addprinc admin/admin"
vi /var/kerberos/krb5kdc/kadm5.acl
/etc/init.d/kadmin start

KERBEROS SETUP:

Adding kerberos user principal:
kadmin.local
addprinc <user>@realm

Re-generating a keytab:
kinit admin/admin@HWX.COM
kadmin
listprinc
xst -k sanju.keytab dn/data7.openstacklocal@HWX.COM
copy the keytab to the desired host

=============================================================== Docker/STE/STF ===============================================================

Create SSH tunnel:

ssh -i <ssh-key> -L <local_port>:<container_ip>:<container_port> -fN ubuntu@<ec2_host>
ssh -i ~/.ssh/sanju_aws.pem -L 18636:172.18.0.3:18636 -fN ubuntu@ec2-34-214-4-253.us-west-2.compute.amazonaws.com
ssh -i ~/.ssh/sanju.pem -L 8042:172.18.0.3:8042 -fN ubuntu@lab

Exposing docker ports:

1) Stop the container ; for container in $(docker ps -q);do echo "$(docker stop $container)"; done
2) Stop docker engine - sudo systemctl stop docker
3) Edit hostconfig.json & config.v2.json

/var/lib/docker/containers/1818a8105b2266ce2b3bae7ab38cee419e0b5db0903d026a0989c3eee2fdbc42/hostconfig.json
/var/lib/docker/containers/1818a8105b2266ce2b3bae7ab38cee419e0b5db0903d026a0989c3eee2fdbc42/config.v2.json

/var/lib/docker/containers/ddf91130dd9b68c808c6f6772530039a30041b38ff58b8e06e5f4b69868c2399/hostconfig.json
/var/lib/docker/containers/ddf91130dd9b68c808c6f6772530039a30041b38ff58b8e06e5f4b69868c2399/config.v2.json

/var/lib/docker/containers/83392dcfef758896cd11ef8c7140fb40b2fb540494c89ef3fea50915047e6e70/hostconfig.json
/var/lib/docker/containers/83392dcfef758896cd11ef8c7140fb40b2fb540494c89ef3fea50915047e6e70/config.v2.json

4) sudo systemctl start docker
5) Start the container

Exposing port on a running container:

docker run -dti --rm --net host bobrik/socat TCP4-LISTEN:7187,fork TCP4:<container-ip>:7187

Find and Kill Docker containers:
docker ps -a | awk '{if (NR!=1) {print "docker stop "$1}}'
docker ps -a | awk '{if (NR!=1) {print "docker rm "$1}}'

CDH :


git clone https://github.com/clusterdock/topology_cdh.git
sudo pip3 install -r topology_cdh/requirements.txt

Non Kerberos:

ste -v start CDH_5.15.0 --kafka-version 3.1.0  --spark2-version 2.3-r2 --sdc-version 3.7.2 --predictable --secondary-nodes node-{2..3}


Kerberos:
clusterdock -v start --namespace streamsets topology_cdh --kerberos --kerberos-principals sdctest --java jdk1.8.0_131 --cdh-version 5.15.0 --cm-version 5.15.0 --kafka-version 2.1.0 --ssl encryption --kudu-version 1.7.0 --predictable --spark2-version 2.3-r2 --sdc-version 3.8.0 --secondary-nodes node-{2..3}

ste -v start CDH_5.15.0_Kerberos --kafka-version 3.1.0  --kudu-version 1.7.0 --spark2-version 2.3-r2 --sdc-version 3.7.2 --predictable --secondary-nodes node-{2..3}
ls ~/.streamsets/testenvironments/CDH_5.15.0_Kerberos/kerberos/
sudo cp ~/.streamsets/testenvironments/CDH_5.15.0_Kerberos/kerberos/clusterdock.keytab ~/sdc-backup.keytab
cp ~/.streamsets/testenvironments/CDH_5.15.0_Kerberos/kerberos/clusterdock.keytab ${SDC_CONTAINER_ID}:/etc/sdc/sdc.keytab
docker cp ~/.streamsets/testenvironments/CDH_5.15.0_Kerberos/kerberos/krb5.conf ${CONTAINER_ID}:/etc/krb5.conf

edit /etc/sdc/sdc.properties

kerberos.client.enabled=true
kerberos.client.principal=sdctest@CLUSTER
kerberos.client.keytab=/etc/sdc/sdc.keytab

Get ticket on shell:

kinit hdfs/node-1.cluster@CLUSTER -kt /var/run/cloudera-scm-agent/process/225-hdfs-NAMENODE/hdfs.keytab

update /etc/hosts
172.18.0.2 node-1.cluster  node1 # clusterdock
172.18.0.3 node-2.cluster  node2 # clusterdock
172.18.0.4 node-3.cluster  node3 # clusterdock
172.18.0.5 kdc.cluster kdc  # clusterdock

MISC:

ln -s /etc/hadoop/conf/hdfs-site.xml hdfs-site.xml
ln -s /etc/hadoop/conf/core-site.xml core-site.xml
ln -s /etc/hadoop/conf/mapred-site.xml mapred-site.xml
ln -s /etc/hadoop/conf/yarn-site.xml yarn-site.xml

Running the tests:

Hadoop stages:
stf -v --testframework-config-directory /home/ubuntu/.streamsets/testenvironments/CDH_5.15.0_Kerberos test -vs --sdc-server-url=http://node-1.cluster:18630 --cluster-server=cm://node-1.cluster:7180 --kerberos stage/test_hadoop_fs_stages.py::test_hadoop_fs_destination
MR:
stf -v --testframework-config-directory /home/ubuntu/.streamsets/testenvironments/CDH_5.15.0_Kerberos test -vs --sdc-server-url=http://node-1.cluster:18630 --cluster-server=cm://node-1.cluster:7180 --kerberos stage/test_mapreduce_executor.py

ControlHub:
=============
cd ~/workspace
git clone https://github.com/streamsets/topology_sch.git -b streamsets
pip3 install -r topology_sch/requirements.txt
clusterdock -v start topology_sch --predictable --sch-version ${SCH_VERSION} --mysql-version 5.7 --influxdb-version 1.4 --system-sdc-version ${SDC_VERSION}

For example:
clusterdock -v start topology_sch --predictable --sch-version 3.9.0 --mysql-version 5.7 --influxdb-version 1.4 --system-sdc-version 3.7.2


Additional SDC instances:

For example:
stf -v start sdc --version 3.7.1 --hostname localhost --sch-server-url http://sch.cluster:18631  --sch-username 'admin@admin' --sch-password 'admin@admin'

STF:
====
 Running tests against Salesforce

 stf -v test -vs --salesforce-username 'test-o7humwfbp3ot@example.com' --salesforce-password 'b$E)2bJs84' --sdc-version 3.8.0-latest  --sdc-server-url http://85fefaa97200:18630 stage/test_salesforce_stages.py
 stf -v test -vs --salesforce-username 'test-o7humwfbp3ot@example.com' --salesforce-password 'b$E)2bJs84' --sdc-version 3.8.0-latest  --sdc-server-url http://ip-172-31-37-183.us-west-2.compute.internal:32769 stage/test_salesforce_stages.py

 stf -v test -vs --salesforce-username 'test-4yyiafjwfgeo@example.com' --salesforce-password 'oyv9UB#4*p' --sdc-version 3.8.0-latest  --sdc-server-url http://node-1.cluster:18630 stage/test_salesforce_stages.py

Contact Object Record:

FirstName,Birthdate,LastName,Email,LeadSource
Sanju,,Chauhan,xtest1@example.com,Advertisement
Siyona,,Chauhan,xtest1@example.com,Advertisement
Shraddha,,Sumit,xtest1@example.com,Advertisement

ElasticSearch:

stf test -vs -m elasticsearch --elasticsearch-url http://elastic:changeme@myelastic.cluster:9200 --sdc-version 3.7.2 --sdc-server-url http://node-1.cluster:18630 stage/test_elasticsearch_stages.py


REST Calls:

# login to Control Hub security app
curl -X POST -d '{"userName":"admin@admin", "password": "admin@admin"}' http://sch.cluster:18631/security/public-rest/v1/authentication/login --header "Content-Type:application/json" --header "X-Requested-By:admin@admin" -c cookie.txt


# generate auth token from security app
sessionToken=$(cat cookie.txt | grep SSO | rev | grep -o '^\S*' | rev)
echo "Generated session token : $sessionToken"

# Call SDC REST APIs using auth token
curl -X GET http://sch.cluster:18631/security/rest/v1/currentUser --header "Content-Type:application/json" --header "X-Requested-By:SCH" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:$sessionToken" -i
curl -X GET http://sch.cluster:18631/policy/rest/v2/persistent/policy/o:seed/pageId=PolicyListPage --header "Content-Type:application/json" --header "X-Requested-By:SCH" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:$sessionToken" -i

curl -X GET http://sch.cluster:18631/pipelinestore/rest/v1/pipelineCommit/8942dd00-471f-4701-b231-312fa90e507b:admin --header "Content-Type:application/json" --header "X-Requested-By:SCH" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:$sessionToken" -i
curl -s -X POST -d '{"userName":"admin@experian”, "password": "12345678"}' https://cloud.streamsets.com/security/public-rest/v1/authentication/login --header "Content-Type:application/json" --header "X-Requested-By:admin"  -D - | grep SS-SSO-LOGIN | sed -e 's/[^=]*=//' -e 's/;.*//'

STREAMSETS CLI:

bin/streamsets cli -U http://localhost:18331 help store import

bin/streamsets cli -U http://node-1.cluster:18343 -a dpm -u admin@admin -p admin@admin --dpmURL http://sch.cluster:18631 store list

bin/streamsets cli -U http://node-1.cluster:18400 -a dpm -u admin@admin -p admin@admin --dpmURL http://sch.cluster:18631 store import -n "Dev to Trash" -f

bin/streamsets cli -U http://localhost:18331 -u admin -p admin store list
bin/streamsets cli -U http://localhost:18331 -u admin -p admin store import -n "Dev to Trash" -f



MapR:
git clone https://github.com/kirtiv1/topology_mapr.git -b handle-mapr-mep-version
clusterdock -v start topology_mapr --namespace streamsets --node-disks='{node-1:[/dev/xvdb],node-2:[/dev/xvdc]}' --predictable --mapr-version 5.2.2 --mep-version 3.0.1 --sdc-version 3.4.3 --port "node-1:18630->18630" --port "node-1:18636->18636"  --predictable


on node-1:
service mapr-zookeeper start
service mapr-warden start
service mapr-cldb restart
on node-2
service mapr-warden start
on node-1:
maprcli node services -name webserver -action start -nodes node-1.cluster

=============================================================== KAFKA ===============================================================

--create topic
kafka-topics --create --zookeeper `hostname`:2181 --replication-factor 1 --partitions 1 --topic test
kafka-topics --create --zookeeper `hostname`:2181 --replication-factor 3 --partitions 3 --topic stats

--list kafka-topics
kafka-topics --list --zookeeper `hostname`:2181

--describe topic

kafka-topics --describe --zookeeper `hostname`:2181 --topic sanju

-- count messages in a topic
kafka-run-class kafka.tools.GetOffsetShell --broker-list `hostname`:9092 --topic source --time -1 --offsets 1 | awk -F  ":" '{sum += $3} END {print sum}'

--Post messages to queue:

kafka-console-producer --broker-list `hostname`:9092 --topic siyona

--post desired number of messages:

while read -r line; do kafka-console-producer.sh --broker-list `hostname`:9092 --topic sanju |  echo $line; done < test.csv

kafka-console-consumer --bootstrap-server `hostname`:9092 --topic sanju --from-beginning

=============================================================== Misc ===============================================================
Java Download on Ubuntu:
sudo apt-get update
wget --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/otn-pub/java/jdk/8u201-b09/42970487e3af4f5aa5bca3f542482c60/jdk-8u201-linux-x64.tar.gz
CentOS:

curl -L -b "oraclelicense=a" -O http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.rpm
sudo yum localinstall jdk-8u181-linux-x64.rpm
sudo alternatives --config java

linux user add - useradd -G
=============================================================== AWS ===============================================================


Configure AWS CLI:

aws configure

List instances by tag/value:

aws ec2 describe-instances --filters "Name=tag:owner,Values=sanjeev"

=============================================================== SMTP ===============================================================


mail.transport.protocol=smtp
mail.smtp.host=smtp.gmail.com
mail.smtp.port=587
mail.smtp.auth=true
mail.smtp.starttls.enable=true
mail.smtps.host=smtp.gmail.com
mail.smtps.port=465
mail.smtps.auth=true
# If 'mail.smtp.auth' or 'mail.smtps.auth' are to true, these properties are used for the user/password credentials,
# ${file("email-password.txt")} will load the value from the 'email-password.txt' file in the config directory (where this file is)
xmail.username=sanjeev@streamsets.com
xmail.password=${file("email-password.txt")}
# FROM email address to use for the messages
xmail.from.address=sanjeev@streamsets.com

=============================================================== SQL ===============================================================

Email,Full Name,Country,User Id,Created At

CREATE TABLE users (
  Name varchar(255) default NULL,
  Country varchar(255) default NULL,
  Id mediumint NOT NULL,
  Email varchar(255) default NULL,
  dt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (Id)
);

INSERT INTO `users` (`Name`,`Country`,`Id`,`Email`) VALUES ("Timothy","Côte D'Ivoire (Ivory Coast)",1,"auctor.vitae@faucibus.edu"),("Steel","Turkey",2,"rhoncus@ante.edu"),("Dean","Liechtenstein",3,"mauris@vulputatelacusCras.com"),("Xavier","Mozambique",4,"Quisque@urnaetarcu.ca"),("Driscoll","Dominican Republic",5,"nec.enim@orciadipiscingnon.ca"),("Igor","Croatia",6,"adipiscing@Suspendisseseddolor.com"),("Seth","Grenada",7,"est.vitae@vel.net"),("Malachi","Cocos (Keeling) Islands",8,"vitae.sodales@congueelitsed.net"),("Jameson","Bulgaria",9,"lectus.a.sollicitudin@Crasvehiculaaliquet.org"),("Mason","Kyrgyzstan",10,"diam.vel.arcu@maurisIntegersem.ca");


LOAD DATA LOCAL INFILE '/tmp/users.csv'
INTO TABLE Users
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n';

CREATE TABLE `Student_Table` (
  `id` mediumint(8) unsigned NOT NULL auto_increment,
  `Student_ID` mediumint,
  `Last_Name` varchar(255) default NULL,
  `First_Name` varchar(255) default NULL,
  `Class_Code` varchar(255) default NULL,
  `Grade_Pt` mediumint default NULL,
  dt DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) AUTO_INCREMENT=1;

MySQL:

create table flights
(Year mediumint ,
Month mediumint ,
DayofMonth mediumint ,
DayOfWeek mediumint ,
DepTime mediumint ,
CRSDepTime mediumint ,
ArrTime mediumint ,
CRSArrTime mediumint ,
UniqueCarrier varchar(255) ,
FlightNum mediumint ,
TailNum varchar(255) ,
ActualElapsedTime mediumint ,
CRSElapsedTime mediumint ,
AirTime varchar(255) ,
ArrDelay mediumint ,
DepDelay mediumint ,
Origin varchar(255) ,
Dest varchar(255) ,
Distance mediumint ,
TaxiIn varchar(255) ,
TaxiOut varchar(255) ,
Cancelled mediumint ,
CancellationCode varchar(255) ,
Diverted mediumint ,
CarrierDelay varchar(255) ,
WeatherDelay varchar(255) ,
NASDelay varchar(255) ,
SecurityDelay varchar(255) ,
LateAircraftDelay varchar(255),
id mediumint(8) unsigned NOT NULL auto_increment,
PRIMARY KEY (id)) AUTO_INCREMENT=1;

LOAD DATA LOCAL INFILE '/tmp/1987.csv' INTO TABLE flights FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '/tmp/1988.csv' INTO TABLE flights FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '/tmp/1989.csv' INTO TABLE flights FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '/tmp/1990.csv' INTO TABLE flights FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '/tmp/1991.csv' INTO TABLE flights FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '/tmp/1992.csv' INTO TABLE flights FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '/tmp/1993.csv' INTO TABLE flights FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE '/tmp/1994.csv' INTO TABLE flights FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';


CREATE TABLE stg_streamed_songs(artist STRING, song STRING, whatever STRING, ts TIMESTAMP) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' STORED AS TEXTFILE;

wget http://stat-computing.org/dataexpo/2009/1987.csv.bz2
wget http://stat-computing.org/dataexpo/2009/1988.csv.bz2
wget http://stat-computing.org/dataexpo/2009/1989.csv.bz2
wget http://stat-computing.org/dataexpo/2009/1990.csv.bz2
wget http://stat-computing.org/dataexpo/2009/1991.csv.bz2
wget http://stat-computing.org/dataexpo/2009/1992.csv.bz2
wget http://stat-computing.org/dataexpo/2009/1993.csv.bz2
wget http://stat-computing.org/dataexpo/2009/1994.csv.bz2
wget http://stat-computing.org/dataexpo/2009/1995.csv.bz2
wget http://stat-computing.org/dataexpo/2009/1996.csv.bz2
wget http://stat-computing.org/dataexpo/2009/1997.csv.bz2
wget http://stat-computing.org/dataexpo/2009/1998.csv.bz2
wget http://stat-computing.org/dataexpo/2009/1999.csv.bz2
wget http://stat-computing.org/dataexpo/2009/2000.csv.bz2
wget http://stat-computing.org/dataexpo/2009/2001.csv.bz2
wget http://stat-computing.org/dataexpo/2009/2002.csv.bz2
wget http://stat-computing.org/dataexpo/2009/2003.csv.bz2
wget http://stat-computing.org/dataexpo/2009/2004.csv.bz2
wget http://stat-computing.org/dataexpo/2009/2005.csv.bz2
wget http://stat-computing.org/dataexpo/2009/2006.csv.bz2
wget http://stat-computing.org/dataexpo/2009/2007.csv.bz2
wget http://stat-computing.org/dataexpo/2009/2008.csv.bz2


create table flights
(Year mediumint ,
Month mediumint ,
DayofMonth mediumint ,
DayOfWeek mediumint ,
DepTime mediumint ,
CRSDepTime mediumint ,
ArrTime mediumint ,
CRSArrTime mediumint ,
UniqueCarrier varchar(255) ,
FlightNum mediumint ,
TailNum varchar(255) ,
ActualElapsedTime mediumint ,
CRSElapsedTime mediumint ,
AirTime varchar(255) ,
ArrDelay mediumint ,
DepDelay mediumint ,
Origin varchar(255) ,
Dest varchar(255) ,
Distance mediumint ,
TaxiIn varchar(255) ,
TaxiOut varchar(255) ,
Cancelled mediumint ,
CancellationCode varchar(255) ,
Diverted mediumint ,
CarrierDelay varchar(255) ,
WeatherDelay varchar(255) ,
NASDelay varchar(255) ,
SecurityDelay varchar(255) ,
LateAircraftDelay varchar(255),
id int unsigned NOT NULL auto_increment,
PRIMARY KEY (id)) AUTO_INCREMENT=1;

PostgreSQL Command:

psql -h ip -U postgres dbname
create database "dbname"
psql -h ip -U postgres dbname < sqlex_backup.pgsql
psql -h ip -U postgres dbname
CREATE ROLE username WITH LOGIN ENCRYPTED PASSWORD 'password';
GRANT CONNECT ON DATABASE dbname TO username;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO username;

MYSQL command:
Set root passsword - $ mysqladmin -u root password NEWPASSWORD
Reset password - mysqladmin -u root -p'oldpassword' password newpass
GRANT ALL PRIVILEGES ON *.* TO 'user'@'host' IDENTIFIED BY 'password' WITH GRANT OPTION;

Test Employee database @ https://github.com/datacharmer/test_db
Test data generator: https://github.com/snowindy/csv-test-data-generator
COLUMNS_DEFINITION - columns definition from http://www.convertcsv.com/generate-test-data.htm (or see below "Allowed Keywords")


Student Table:

DROP TABLE Student_Table;

CREATE TABLE Student_Table (
  id mediumint(8) unsigned NOT NULL auto_increment,
  Student_ID mediumint,
 Last_Name varchar(255) default NULL,
  First_Name varchar(255) default NULL,
  Class_Code varchar(255) default NULL,
  Grade_Pt mediumint default NULL,
  PRIMARY KEY (id)
) AUTO_INCREMENT=1;

INSERT INTO `Student_Table` (`Student_ID`,`Last_Name`,`First_Name`,`Class_Code`,`Grade_Pt`) VALUES (100,"Mark","Gretchen","SO",5),(101,"Hyatt","Kellie","SR",5),(102,"Reece","Selma","SO",1),(103,"Jameson","Zoe","SR",7),(104,"Matthew","Athena","",5),(105,"Erich","Iliana","FR",2),(106,"Bruno","Shellie","FR",7),(107,"Cairo","Margaret","SO",2),(108,"Ciaran","Kyra","JR",3),(109,"Bert","Zephr","",6),(110,"Hamilton","Tallulah","SR",7),(111,"Curran","Eleanor","JR",4),(112,"Graham","Kelly","SO",5),(113,"Reed","Brenna","",10),(114,"Keegan","Keiko","SO",10),(115,"Jason","Chiquita","JR",6),(116,"Walker","Halla","FR",10),(117,"Jameson","Echo","JR",7),(118,"Byron","Judith","SO",6),(119,"Thaddeus","Ursula","SR",3),(120,"Aaron","Marny","SO",10),(121,"Lionel","Imogene","SR",7),(122,"Thane","Ciara","JR",3),(123,"Linus","Debra","SR",5),(124,"Caldwell","Keiko","",9),(125,"Omar","Irene","SO",1),(126,"Cole","India","",7),(127,"Tanek","Rhonda","JR",2),(128,"Isaiah","Sandra","FR",4),(129,"Chancellor","Elaine","",2),(130,"Edan","Brielle","JR",3),(131,"Nero","Joy","JR",2),(132,"Elijah","Kathleen","SR",7),(133,"Caleb","Bertha","SO",7),(134,"Kasper","Samantha","FR",3),(135,"Philip","Hedda","SR",2),(136,"Chadwick","Stephanie","JR",1),(137,"John","Lacy","FR",5),(138,"Todd","Deborah","SR",3),(139,"Orson","Alexandra","FR",10),(140,"Hyatt","Ivy","SO",1),(141,"Michael","Ruby","SO",5),(142,"Jesse","Nicole","FR",8),(143,"Malachi","Hedy","FR",3),(144,"Holmes","Yolanda","JR",3),(145,"Holmes","Amaya","SR",3),(146,"Cruz","Dakota","JR",5),(147,"Herman","Rachel","SO",1),(148,"Vernon","Inez","SO",8),(149,"Robert","Nichole","JR",6),(150,"Brenden","Ramona","JR",4),(151,"Anthony","Shay","JR",3),(152,"Walker","Cameron","FR",4),(153,"Rigel","Kiara","JR",10),(154,"Colton","Desiree","SR",4),(155,"Cyrus","Ruby","SO",7),(156,"Arsenio","Dai","",6),(157,"Randall","Fatima","FR",6),(158,"Peter","Regan","SR",1),(159,"Merrill","Jenette","SR",8),(160,"Neil","Yvonne","",5),(161,"Edan","Bethany","SR",9),(162,"Jerry","Lani","FR",3),(163,"Lev","Cherokee","SR",1),(164,"Ryder","Phoebe","SO",1),(165,"Stewart","Shaeleigh","JR",4),(166,"Ahmed","Quintessa","",8),(167,"Abel","Giselle","SR",4),(168,"Alvin","Hermione","SR",1),(169,"Nasim","Brynne","SR",9),(170,"Connor","Ivory","SR",5),(171,"Moses","Tamara","",2),(172,"Jack","Zelenia","SO",10),(173,"Tyler","Ora","",4),(174,"Ali","Nola","SR",6),(175,"Gray","Victoria","FR",5),(176,"Alexander","Montana","JR",8),(177,"Allistair","Zelda","",1),(178,"Herman","Jemima","",2),(179,"Myles","Britanni","SO",6),(180,"Devin","Heather","",9),(181,"Dustin","Mechelle","FR",1),(182,"Tanek","Blythe","SR",7),(183,"Lester","Shaeleigh","FR",10),(184,"Phelan","Daryl","JR",6),(185,"Kadeem","Minerva","",5),(186,"Elijah","Orli","",4),(187,"Aladdin","Cameran","FR",5),(188,"Paul","Althea","JR",8),(189,"Hyatt","Ivory","FR",10),(190,"Kasimir","Daphne","JR",9),(191,"Isaac","Aiko","JR",5),(192,"Porter","Stella","SR",10),(193,"Joseph","Maile","JR",1),(194,"Devin","Tanisha","SO",6),(195,"Kermit","Cally","JR",5),(196,"Abel","Autumn","",3),(197,"Garrison","Lysandra","SO",8),(198,"Nash","Ora","",9),(199,"Cade","Priscilla","SR",7);

DROP TABLE Sales_Data;

CREATE TABLE Sales_Data (
  product_id mediumint default NULL,
  sale_date varchar(255),
  daily_sales mediumint default NULL
);

INSERT INTO Sales_Data (product_id,sale_date,daily_sales) VALUES (1001,"2019-01-14T08:16:34-08:00",4847),(1000,"2018-11-09T10:21:01-08:00",1275),(1006,"2017-10-18T18:37:24-07:00",5047),(1000,"2017-10-23T13:08:09-07:00",7966),(1005,"2017-12-18T07:49:06-08:00",4336),(1000,"2018-08-06T14:45:49-07:00",3401),(1001,"2018-03-14T12:40:36-07:00",8416),(1007,"2017-11-18T21:39:35-08:00",8048),(1008,"2017-06-04T15:56:15-07:00",1166),(1010,"2017-09-26T02:26:52-07:00",5722),(1008,"2018-01-10T04:04:29-08:00",6742),(1005,"2018-07-23T05:11:35-07:00",404),(1001,"2018-07-30T11:52:05-07:00",799),(1000,"2018-04-04T17:10:09-07:00",5037),(1006,"2018-11-01T00:47:22-07:00",174),(1009,"2017-10-16T12:58:00-07:00",6924),(1004,"2017-04-01T13:36:32-07:00",7240),(1007,"2017-05-20T23:51:47-07:00",5251),(1000,"2017-03-23T07:16:35-07:00",7262),(1005,"2018-09-30T11:30:03-07:00",4791),(1001,"2018-05-13T15:28:04-07:00",3059),(1004,"2018-06-20T16:45:41-07:00",4193),(1005,"2017-12-28T01:47:59-08:00",6416),(1005,"2018-07-18T23:59:18-07:00",5569),(1009,"2018-07-17T20:45:02-07:00",5819),(1002,"2017-12-13T18:12:39-08:00",9905),(1001,"2017-12-15T05:12:02-08:00",9843),(1006,"2017-12-17T06:18:05-08:00",8547),(1009,"2019-02-05T12:24:19-08:00",5502),(1003,"2017-10-01T01:05:06-07:00",1093),(1006,"2018-05-21T13:25:57-07:00",4166),(1002,"2017-09-24T01:23:19-07:00",4911),(1002,"2017-09-28T15:05:23-07:00",1777),(1001,"2018-07-30T17:31:40-07:00",9290),(1006,"2017-07-11T17:03:03-07:00",8922),(1001,"2017-09-26T12:51:56-07:00",9271),(1009,"2017-07-08T05:03:06-07:00",4701),(1008,"2017-04-20T19:06:53-07:00",1955),(1008,"2017-03-16T17:50:15-07:00",5311),(1001,"2018-01-16T23:26:09-08:00",8933),(1008,"2018-04-29T12:07:59-07:00",9527),(1006,"2019-02-02T06:10:01-08:00",2213),(1005,"2018-11-16T19:51:48-08:00",144),(1002,"2018-04-07T16:34:00-07:00",3139),(1005,"2017-08-19T01:00:04-07:00",6011),(1003,"2018-08-14T09:51:32-07:00",2172),(1006,"2017-03-30T02:04:59-07:00",6169),(1009,"2017-11-16T05:42:21-08:00",2834),(1004,"2017-04-02T00:43:52-07:00",3054),(1003,"2017-07-29T10:23:38-07:00",8786),(1000,"2017-10-19T22:46:27-07:00",1325),(1003,"2018-05-14T14:20:57-07:00",5610),(1001,"2017-07-08T19:21:31-07:00",403),(1007,"2018-04-23T07:23:32-07:00",7322),(1001,"2017-07-10T14:29:25-07:00",6774),(1009,"2018-03-20T16:49:30-07:00",1130),(1006,"2018-01-26T11:16:01-08:00",251),(1008,"2018-10-10T09:10:20-07:00",2899),(1009,"2019-02-10T12:20:36-08:00",8771),(1002,"2018-11-23T15:11:18-08:00",9462),(1003,"2017-08-26T15:56:11-07:00",6178),(1009,"2018-02-14T01:55:37-08:00",146),(1003,"2018-08-13T20:31:08-07:00",772),(1002,"2018-10-19T05:12:52-07:00",2913),(1010,"2018-08-15T05:54:07-07:00",9931),(1001,"2018-09-12T14:03:27-07:00",6264),(1002,"2018-11-27T07:53:31-08:00",4255),(1003,"2017-03-16T03:29:40-07:00",5082),(1001,"2019-02-13T18:44:03-08:00",8985),(1004,"2018-04-26T10:55:24-07:00",9746),(1001,"2017-10-01T11:48:13-07:00",1383),(1007,"2017-10-31T09:27:48-07:00",5874),(1004,"2018-01-13T05:16:20-08:00",860),(1005,"2019-03-04T10:49:55-08:00",1927),(1005,"2018-09-02T14:21:28-07:00",9549),(1009,"2018-08-01T22:47:21-07:00",6562),(1010,"2018-06-01T07:20:52-07:00",2255),(1001,"2017-06-05T10:29:16-07:00",630),(1007,"2018-04-27T17:26:01-07:00",8015),(1001,"2018-03-25T22:12:22-07:00",203),(1009,"2018-10-05T11:54:08-07:00",212),(1000,"2018-12-17T15:17:53-08:00",9956),(1002,"2018-02-25T00:15:31-08:00",5038),(1001,"2018-05-23T02:58:43-07:00",1665),(1004,"2017-07-11T22:27:59-07:00",9316),(1003,"2017-09-13T21:09:09-07:00",8492),(1006,"2018-08-17T09:45:32-07:00",2680),(1004,"2018-09-16T08:04:56-07:00",1962),(1009,"2018-10-06T15:14:52-07:00",1945),(1000,"2018-09-12T05:26:35-07:00",1655),(1006,"2019-01-24T16:38:56-08:00",4594),(1004,"2017-06-24T05:03:35-07:00",5416),(1000,"2018-06-11T21:31:37-07:00",6018),(1003,"2018-12-25T22:46:47-08:00",5987),(1000,"2018-03-09T04:54:59-08:00",8235),(1009,"2018-11-18T19:55:17-08:00",9840),(1004,"2018-10-24T11:53:36-07:00",9699),(1001,"2018-12-14T07:49:01-08:00",7832),(1002,"2017-04-19T14:07:58-07:00",83),(1007,"2018-11-15T02:36:07-08:00",4331);

HIVE:

LOAD DATA LOCAL INFILE '/tmp/1987.csv' INTO TABLE onTimePerfStage FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';

HIVE:

create table flights
(Year INT ,
Month INT ,
DayofMonth INT ,
DayOfWeek INT ,
DepTime INT ,
CRSDepTime INT ,
ArrTime INT ,
CRSArrTime INT ,
UniqueCarrier STRING ,
FlightNum INT ,
TailNum STRING ,
ActualElapsedTime INT ,
CRSElapsedTime INT ,
AirTime STRING ,
ArrDelay INT ,
DepDelay INT ,
Origin STRING ,
Dest STRING ,
Distance INT ,
TaxiIn STRING ,
TaxiOut STRING ,
Cancelled INT ,
CancellationCode STRING ,
Diverted INT ,
CarrierDelay STRING ,
WeatherDelay STRING ,
NASDelay STRING ,
SecurityDelay STRING ,
LateAircraftDelay STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

LOAD DATA LOCAL INPATH "/tmp/1987.csv" OVERWRITE INTO TABLE flights;


create table onTimePerf
(DayofMonth INT ,
DayOfWeek INT ,
DepTime INT ,
CRSDepTime INT ,
ArrTime INT ,
CRSArrTime INT ,
UniqueCarrier STRING ,
FlightNum INT ,
TailNum STRING ,
ActualElapsedTime INT ,
CRSElapsedTime INT ,
AirTime STRING ,
ArrDelay INT ,
DepDelay INT ,
Origin STRING ,
Dest STRING ,
Distance INT ,
TaxiIn STRING ,
TaxiOut STRING ,
Cancelled INT ,
CancellationCode STRING ,
Diverted INT ,
CarrierDelay STRING ,
WeatherDelay STRING ,
NASDelay STRING ,
SecurityDelay STRING ,
LateAircraftDelay STRING)
PARTITIONED BY (Year INT, Month INT )
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

SET hive.exec.dynamic.partition = true;
SET hive.exec.dynamic.partition.mode = nonstrict;
INSERT OVERWRITE TABLE onTimePerf PARTITION(Year, Month) SELECT DayofMonth, DayOfWeek, DepTime, CRSDepTime, ArrTime, CRSArrTime, UniqueCarrier, FlightNum, TailNum, ActualElapsedTime, CRSElapsedTime, AirTime, ArrDelay, DepDelay, Origin, Dest, Distance, TaxiIn, TaxiOut, Cancelled, CancellationCode, Diverted, CarrierDelay, WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay, Year, Month FROM onTimePerfStage;

Dataset:https://drive.google.com/file/d/0B_Qjau8wv1KoWTVDUVFOdzlJNWM/view?usp=sharing

ORC vs Parquet
===============
data - https://raw.githubusercontent.com/hortonworks/data-tutorials/1f3893c64bbf5ffeae4f1a5cbf1bd667dcea6b06/tutorials/hdp/hdp-2.6/beginners-guide-to-apache-pig/assets/driver_data.zip
Data cleaning: cat /Users/sanju/workspace/Data/DelayedFlights.csv | awk -F ',' '{print $2 "," $3 "," $11 "," $18 "," $19 "," $23 "," $24 "," $25}' > /Users/sanju/workspace/Data/DelayedFlightsSubset.csv

Schema:

create table aviation_stg(
year INT,
month INT,
flight_num INT,
origin STRING,
destination STRING,
cancelled INT,
cancel_code STRING,
diversion INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE
TBLPROPERTIES ("skip.header.line.count"="1");

load data local inpath '/tmp/DelayedFlightsSubset.csv' into table aviation_stg;

create table aviation_orc(
year INT,
month INT,
flight_num INT,
origin STRING,
destination STRING,
cancelled INT,
cancel_code STRING,
diversion INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS ORC
TBLPROPERTIES ("orc.compress"="SNAPPY");

INSERT OVERWRITE TABLE aviation_orc SELECT * FROM aviation_stg;

create table aviation_parq(
year INT,
month INT,
flight_num INT,
origin STRING,
destination STRING,
cancelled INT,
cancel_code STRING,
diversion INT
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS PARQUET
TBLPROPERTIES ("orc.compress"="SNAPPY");

HBASE:
create 'emp', 'personal data', 'professional data'
put 'emp','1','personal data:name','raju'
put 'emp','1','personal data:city','hyderabad'
put 'emp','1','professional data:designation','manager'
put 'emp','1','professional data:salary','50000'


mysql -u ambari -p
mysqldump --all-databases > /tmp/hdptest.sql

Restore:
mysql -u root -p
mysql> create database mydb;
mysql> use mydb;
mysql> source db_backup.dump;
OR
mysql --max_allowed_packet=100M -u root -p database < dump.sql