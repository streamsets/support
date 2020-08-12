#!/bin/bash
# ------------ Postgresql Database setup ------------- #
USER=schadmin
PASS=redhat
OS_VERSION=`rpm -q --queryformat '%{VERSION}' centos-release`
        if [ "$OS_VERSION" -eq 7 ]
        then
                rpm -Uvh https://yum.postgresql.org/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm
		yum install postgresql10-server postgresql10 postgresql-jdbc -y 
		/usr/pgsql-10/bin/postgresql-10-setup initdb
		systemctl start postgresql-10.service
		systemctl enable postgresql-10.service
sleep 5
subnet=`ip -o -f inet addr show | awk '/scope global/ {print $4}'|head -1`
echo "local   all             all                             md5">>/var/lib/pgsql/10/data/pg_hba.conf
echo "host  all    	    	all            $subnet      trust">>/var/lib/pgsql/10/data/pg_hba.conf
echo "host    all           	all            127.0.0.1/32          md5">>/var/lib/pgsql/10/data/pg_hba.conf
echo "listen_addresses = '*'">>/var/lib/pgsql/10/data/postgresql.conf
       
systemctl restart postgresql-10.service

 else
                amazon-linux-extras install postgresql10 vim epel -y
		amazon-linux-extras  install java-openjdk11 -y
		yum install java-1.8.0-openjdk -y
		yum install -y postgresql-server postgresql-devel postgresql-jdbc
		/usr/bin/postgresql-setup --initdb
			systemctl enable postgresql
		systemctl start postgresql
sleep 5		
subnet=`ip -o -f inet addr show | awk '/scope global/ {print $4}'|head -1`
echo "local   all             all                             md5">>/var/lib/pgsql/data/pg_hba.conf
echo "host  all                 all            $subnet      trust">>/var/lib/pgsql/data/pg_hba.conf
echo "host    all               all            127.0.0.1/32          md5">>/var/lib/pgsql/data/pg_hba.conf
echo "listen_addresses = '*'">>/var/lib/pgsql/data/postgresql.conf
		                
service postgresql restart
        
fi
useradd $USER
echo "$PASS" |passwd $USER --stdin
sudo -u postgres psql << EOF
CREATE USER schadmin WITH PASSWORD 'redhat';
ALTER USER schadmin CREATEDB;
CREATE DATABASE security;
CREATE DATABASE pipelinestore;
CREATE DATABASE messaging;
CREATE DATABASE jobrunner;
CREATE DATABASE topology;
CREATE DATABASE notification;
CREATE DATABASE sla;
CREATE DATABASE timeseries;
CREATE DATABASE provisioning;
CREATE DATABASE scheduler;
CREATE DATABASE reporting;
CREATE DATABASE sdp_classification;
CREATE DATABASE policy;
CREATE DATABASE dynamic_preview;
grant all privileges on database dynamic_preview to schadmin;
grant all privileges on database jobrunner to schadmin;
grant all privileges on database messaging to schadmin;
grant all privileges on database notification to schadmin;
grant all privileges on database pipelinestore to schadmin;
grant all privileges on database policy to schadmin;
grant all privileges on database provisioning to schadmin;
grant all privileges on database reporting to schadmin;
grant all privileges on database scheduler to schadmin;
grant all privileges on database sdp_classification to schadmin;
grant all privileges on database security to schadmin;
grant all privileges on database sla to schadmin;
grant all privileges on database timeseries to schadmin;
grant all privileges on database topology to schadmin;
EOF
		echo "Postgresql user created."
		echo "Username:   $USER"
		echo "Password:   $PASS"

# ----------------- INFLUXDB Setup --------------- #
wget https://dl.influxdata.com/influxdb/releases/influxdb-0.13.0.x86_64.rpm
yum localinstall influxdb-0.13.0.x86_64.rpm -y
systemctl start influxdb 
systemctl enable influxdb
 
influx -execute 'CREATE DATABASE sch'
influx -execute 'CREATE DATABASE sch_app'
curl "http://localhost:8086/query" --data-urlencode "q=CREATE USER schadmin WITH PASSWORD 'redhat' WITH ALL PRIVILEGES"
influx -execute 'grant ALL on sch to schadmin'
influx -execute 'grant ALL on sch_app to schadmin'
influx -execute 'grant read on _internal to schadmin'



#----------------- SCH Installation --------------#
OS_VERSION=`rpm -q --queryformat '%{VERSION}' centos-release`
        if [ "$OS_VERSION" -eq 7 ]
        then
		HOSTNAME=`hostname -f`
	else
		HOSTNAME=`hostname -f`
	fi
rm -rf /opt/controlhub
/usr/bin/mkdir -p /opt/controlhub
LOC=/opt/controlhub
echo "Please select the version which you want to install from the below list !!"
echo -e "-> 3.15.0\n-> 3.14.0\n-> 3.10.0-0015\n-> 3.13.1\n-> 3.13.0\n-> 3.12.1\n-> 3.12.0\n-> 3.11.1\n-> 3.11.0-0012\n-> 3.10.0\n-> 3.9.0-0007\n-> 3.9.0\n-> 3.8.0\n-> 3.7.1\n-> 3.6.0\n-> 3.5.0"
read -p "Enter Your SCH version: "  VERSION
echo $VERSION
wget --directory-prefix=$LOC --user=onpremadmin --password=8237MnN4jV# https://on-prem.streamsets.com/$VERSION-ONPREM/streamsets-dpm-$VERSION.tgz --no-check-certificate
sleep 5
cd $LOC
/usr/bin/tar -xvf streamsets-dpm-$VERSION.tgz -C $LOC


dpm_home="/opt/controlhub/streamsets-dpm-$VERSION"
dpm_conf="/opt/controlhub/streamsets-dpm-$VERSION/etc"

echo "export DPM_LOG=$dpm_home/log">>"${dpm_home}"/libexec/dpm-env.sh
echo "export DPM_CONF=$dpm_conf">>"${dpm_home}"/libexec/dpm-env.sh
echo "export DPM_HOME=$dpm_home">>"${dpm_home}"/libexec/dpm-env.sh


echo "Do you wants to enable SSL for SCH  !!"
echo "Yes/No"
read -p "Enter [y/N]: "  response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		name=sch
		HOSTNAME=`hostname -f`
###### SSL certs and keystore, truststore setup
		/usr/bin/mkdir -p /opt/controlhub/ssl
		cd /opt/controlhub/ssl
		openssl genrsa -out ca.key 8192
		openssl req -new -x509 -extensions v3_ca -key /opt/controlhub/ssl/ca.key -out /opt/controlhub/ssl/ca.crt -days 365 -subj "/C=CL/ST=KA/L=Karnataka/O=Streamsets/OU=Support/CN=$HOSTNAME"
		openssl genrsa -out $name.key 2048
		openssl req -new -sha256 -key $name.key -out $name.csr -subj "/C=CL/ST=KA/L=Karnataka/O=Streamsets/OU=Support/CN=$HOSTNAME"
		openssl x509 -req -CA /opt/controlhub/ssl/ca.crt -CAkey /opt/controlhub/ssl/ca.key -in $name.csr -out $name.crt -days 365 -CAcreateserial
	sleep 2
		openssl pkcs12 -export -inkey $name.key -in $name.crt -certfile /opt/controlhub/ssl/ca.crt -out $name.pfx -password pass:changeit
		/usr/bin/keytool -v -importkeystore -srckeystore $name.pfx -srcstorepass changeit -srcstoretype PKCS12 -destkeystore $name.jks -deststoretype JKS -srcalias 1 -destalias $name -deststorepass changeit -destkeypass changeit       
       		/usr/bin/keytool -import -keystore /opt/controlhub/ssl/truststore.jks -alias rootca -file /opt/controlhub/ssl/ca.crt -storepass changeit -noprompt
		echo "export DPM_JAVA_OPTS=\"-Djavax.net.ssl.trustStore=/opt/controlhub/ssl/truststore.jks -Djavax.net.ssl.trustStorePassword=changeit\"">>"${dpm_home}"/libexec/dpm-env.sh
               	KEYSTORE=/opt/controlhub/ssl/$name.jks
		 echo "dpm.base.url=https://$HOSTNAME:19631" >> "${dpm_conf}"/dpm.properties 
		sed -i.bak "s/^[#]*\s*http.port=.*/http.port=-1/" "${dpm_conf}"/dpm.properties
		sed -i.bak "s/^[#]*\s*https.port=.*/https.port=19631/" "${dpm_conf}"/dpm.properties
		sed -i.bak "s~https.keystore.path=.*~https.keystore.path=${KEYSTORE}~" "${dpm_conf}"/dpm.properties
		sed -i.bak "s/^[#]*\s*https.keystore.password=.*/https.keystore.password=changeit/" "${dpm_conf}"/dpm.properties
		sed -i.bak "s/^[#]*\s*admin.http.port=.*/admin.http.port=-1/" "${dpm_conf}"/dpm.properties
		sed -i.bak "s/^[#]*\s*admin.https.port=.*/admin.https.port=19632/" "${dpm_conf}"/dpm.properties
                sed -i.bak "s~admin.https.keystore.path=.*~admin.https.keystore.path=${KEYSTORE}~" "${dpm_conf}"/dpm.properties
		sed -i.bak "s/^[#]*\s*admin.https.keystore.password=.*/admin.https.keystore.password=changeit/" "${dpm_conf}"/dpm.properties

		for app in dynamic_preview security jobrunner messaging pipelinestore provisioning timeseries topology notification sla scheduler reporting sdp_classification policy;
		do
			echo "dpm.app."${app}".url=https://$HOSTNAME:19631" >> $dpm_conf/common-to-all-apps.properties

		done


sed -i.back 's/4096/200/g' "${dpm_home}"/libexec/dpm-env.sh
cp /usr/share/java/postgresql-jdbc.jar  $dpm_home/extra-lib

		for app in dynamic_preview security jobrunner messaging pipelinestore provisioning timeseries topology notification sla scheduler reporting sdp_classification policy; 
		do

sed -i.bak "s/^[#]*\s*db.openjpa.ConnectionUserName=.*/db.openjpa.ConnectionUserName=$USER/" "${dpm_conf}"/"${app}"-app.properties
sed -i.bak "s/^[#]*\s*db.openjpa.ConnectionDriverName=.*/db.openjpa.ConnectionDriverName=org.postgresql.Driver/" "${dpm_conf}"/"${app}"-app.properties
sed -i.bak "s~db.openjpa.ConnectionURL=.*~db.openjpa.ConnectionURL=jdbc:postgresql://"${HOSTNAME}":5432/"${app}"~" "${dpm_conf}"/"${app}"-app.properties
sed -i.bak "s/^[#]*\s*db.openjpa.ConnectionPassword=.*/db.openjpa.ConnectionPassword="${PASS}"/" "${dpm_conf}"/"${app}"-app.properties
sed -i.bak "s/^[#]*\s*org.quartz.jobStore.driverDelegateClass = org.quartz.impl.jdbcjobstore.PostgreSQLDelegate/org.quartz.jobStore.driverDelegateClass = org.quartz.impl.jdbcjobstore.PostgreSQLDelegate/" "${dpm_conf}"/scheduler-app.properties

		done

# ------------------ timeseries-app ------------------ #

#Example influx db url
echo "db.url=http://$HOSTNAME:8086">>$dpm_conf/timeseries-app.properties
echo "db.name=sch">>$dpm_conf/timeseries-app.properties
echo "db.user=$USER">>$dpm_conf/timeseries-app.properties
echo "db.password=$PASS">>$dpm_conf/timeseries-app.properties
echo "db.retentionPolicy=autogen">>$dpm_conf/timeseries-app.properties
#Example influx app db url
echo "dpm.app.db.url=http://$HOSTNAME:8086">>$dpm_conf/timeseries-app.properties
echo "dpm.app.db.name=sch_app">>$dpm_conf/timeseries-app.properties
echo "dpm.app.db.user=$USER">>$dpm_conf/timeseries-app.properties
echo "dpm.app.db.password=$PASS">>$dpm_conf/timeseries-app.properties
echo "dpm.app.db.retentionPolicy=autogen">>$dpm_conf/timeseries-app.properties

echo "dpm.base.url=https://$HOSTNAME:19631">>$dpm_conf/common-to-all-apps.properties
echo "dpm.base.url=https://$HOSTNAME:19631">>$dpm_conf/dpm.properties
echo "admin:MD5:21232f297a57a5a743894a0e4a801fc3,user,sys-admin">>$dpm_conf/basic-realm.properties
# ----------------- Schema build script ----------------- #

cd $dpm_home;dev/01-initdb.sh
sleep 3
sudo -u schadmin psql -U $USER timeseries <<ADD_INDEX
create index comp_idx on LATEST_METRICS (JOB_ID, LAST_UPDATED_TIME);
ADD_INDEX

# ----------------- Generation of Authentication token ----------------- #
cd $dpm_home;dev/02-initsecurity.sh
sleep 3
# ----------------- Retrive Control Hub System ID ---------------------- #
cd $dpm_home;dev/01-initdb.sh
bin/streamsets dpmcli security systemId -c
cd $dpm_home
bin/streamsets dpm  >/dev/null 2>$dpm_home/err.txt &
sleep 250

		echo "Complete Installation is Done"
                HOSTNAME=`hostname -f`
                echo "Please try to open the SCH UI at https://$HOSTNAME:19631"
                echo "Please try to open the SCH Admin UI at https://$HOSTNAME:19632/admin.html"



else

			sed -i.back 's/4096/200/g' "${dpm_home}"/libexec/dpm-env.sh
			cp /usr/share/java/postgresql-jdbc.jar  $dpm_home/extra-lib

for app in dynamic_preview security jobrunner messaging pipelinestore provisioning timeseries topology notification sla scheduler reporting sdp_classification policy;
do

sed -i.bak "s/^[#]*\s*db.openjpa.ConnectionUserName=.*/db.openjpa.ConnectionUserName=$USER/" "${dpm_conf}"/"${app}"-app.properties
sed -i.bak "s/^[#]*\s*db.openjpa.ConnectionDriverName=.*/db.openjpa.ConnectionDriverName=org.postgresql.Driver/" "${dpm_conf}"/"${app}"-app.properties
sed -i.bak "s~db.openjpa.ConnectionURL=.*~db.openjpa.ConnectionURL=jdbc:postgresql://"${HOSTNAME}":5432/"${app}"~" "${dpm_conf}"/"${app}"-app.properties
sed -i.bak "s/^[#]*\s*db.openjpa.ConnectionPassword=.*/db.openjpa.ConnectionPassword="${PASS}"/" "${dpm_conf}"/"${app}"-app.properties
sed -i.bak "s/^[#]*\s*org.quartz.jobStore.driverDelegateClass = org.quartz.impl.jdbcjobstore.PostgreSQLDelegate/org.quartz.jobStore.driverDelegateClass = org.quartz.impl.jdbcjobstore.PostgreSQLDelegate/" "${dpm_conf}"/scheduler-app.properties

done

# ------------------ common-to-all-apps -------------- #
#$dpm_conf/common-to-all-apps.properties

for app in dynamic_preview security jobrunner messaging pipelinestore provisioning timeseries topology notification sla scheduler reporting sdp_classification policy;
do
echo "dpm.app."${app}".url=http://$HOSTNAME:18631" >> $dpm_conf/common-to-all-apps.properties

done

# ------------------ timeseries-app ------------------ #

#Example influx db url
echo "db.url=http://$HOSTNAME:8086">>$dpm_conf/timeseries-app.properties
echo "db.name=sch">>$dpm_conf/timeseries-app.properties
echo "db.user=$USER">>$dpm_conf/timeseries-app.properties
echo "db.password=$PASS">>$dpm_conf/timeseries-app.properties
echo "db.retentionPolicy=autogen">>$dpm_conf/timeseries-app.properties
#Example influx app db url
echo "dpm.app.db.url=http://$HOSTNAME:8086">>$dpm_conf/timeseries-app.properties
echo "dpm.app.db.name=sch_app">>$dpm_conf/timeseries-app.properties
echo "dpm.app.db.user=$USER">>$dpm_conf/timeseries-app.properties
echo "dpm.app.db.password=$PASS">>$dpm_conf/timeseries-app.properties
echo "dpm.app.db.retentionPolicy=autogen">>$dpm_conf/timeseries-app.properties

echo "dpm.base.url=http://$HOSTNAME:18631">>$dpm_conf/common-to-all-apps.properties 
echo "dpm.base.url=http://$HOSTNAME:18631">>$dpm_conf/dpm.properties
echo "admin:MD5:21232f297a57a5a743894a0e4a801fc3,user,sys-admin">>$dpm_conf/basic-realm.properties
# ----------------- Schema build script ----------------- #

cd $dpm_home;dev/01-initdb.sh
sleep 3
sudo -u schadmin psql -U $USER timeseries <<ADD_INDEX
create index comp_idx on LATEST_METRICS (JOB_ID, LAST_UPDATED_TIME);
ADD_INDEX

# ----------------- Generation of Authentication token ----------------- #
cd $dpm_home;dev/02-initsecurity.sh
sleep 3
# ----------------- Retrive Control Hub System ID ---------------------- #
cd $dpm_home;dev/01-initdb.sh
bin/streamsets dpmcli security systemId -c
cd $dpm_home
bin/streamsets dpm  >/dev/null 2>$dpm_home/err.txt &

sleep 250

		echo "Complete Installation is Done"
                HOSTNAME=`hostname -f`
        	echo "Please try to open the SCH UI at http://$HOSTNAME:18631"
		echo "Please try to open the SCH Admin UI at http://$HOSTNAME:18632/admin.html"

fi
