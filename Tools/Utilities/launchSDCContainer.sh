
# README
#=========
: '

This script can be used to launch a SDC docker container with all the stagelib

Usage: sh launchSDCContainer.sh OR ./launchSDCContainer.sh

Pre-Req:
Set following env variables:
SDC_DOWNLOAD_USER (defaulted to 'StreamSets')
SDC_DOWNLOAD_PASSWORD --> https://support.streamsets.com/hc/en-us/articles/360046575233-StreamSets-Data-Collector-and-Transformer-Binaries-Download

'

BYellow='\033[1;33m' # Foreground BYellow
On_Yellow='\033[33;5;7m' #Backgroud BYellow
Color_Off='\033[0m' # No Color

log() {
    printf "\n${BYellow}$1${Color_Off} \n"
}

read -p 'SDC_VERSION: ' SDC_VERSION
#read -p 'SDC_PORT: ' SDC_PORT
#SDC_PORT=${SDC_PORT:-18630}

# Retrive password from env variable
SDC_DOWNLOAD_PASSWORD1=$SDC_DOWNLOAD_PASSWORD
STREAMSETS_DOWNLOAD_URL=https://downloads.streamsets.com/datacollector
SDC_DOWNLOAD_DIR=SDC

read -p 'SDC_DOWNLOAD_USER[StreamSets]:' SDC_DOWNLOAD_USER
SDC_DOWNLOAD_USER=${SDC_DOWNLOAD_USER:-StreamSets}

read -p 'SDC_DOWNLOAD_PASSWORD: ' SDC_DOWNLOAD_PASSWORD
SDC_DOWNLOAD_PASSWORD=${SDC_DOWNLOAD_PASSWORD:-$SDC_DOWNLOAD_PASSWORD1}
printf "\n"


SDC_CONF="sdc-conf-$(echo "$SDC_VERSION" | tr . -)"
SDC_DATA="sdc-data-$(echo "$SDC_VERSION" | tr . -)"
SDC_LIBS="sdc-stage-libs-$(echo "$SDC_VERSION" | tr . -)"
CONTAINER_NAME="sdc-$(echo "$SDC_VERSION" | tr -d . | cut -c1-3)"
SDC_PORT="18$(echo "$SDC_VERSION" | tr -d . | cut -c1-3)"

# Check if docker volume exists with the same name

if [ $(sudo ls /var/lib/docker/volumes/ | grep $SDC_CONF) == "" ]
 then
      # create docker volume to preserve pipeline data and configuration
      log 'Creating docker volumes '
      docker volume create --name $SDC_CONF
      docker volume create --name $SDC_DATA
      docker volume create --name $SDC_LIBS
 else
      log 'Cleaning up existing Docker volumes and re-creating '
      docker stop $CONTAINER_NAME
      docker rm $CONTAINER_NAME
      docker volume rm $SDC_CONF
      docker volume rm $SDC_DATA
      docker volume rm $SDC_LIBS
      docker volume create --name $SDC_CONF
      docker volume create --name $SDC_DATA
      docker volume create --name $SDC_LIBS
fi

if [ ! -d "/$HOME/$SDC_DOWNLOAD_DIR" ]
  then
    printf "\nDownload dir doesn't exists. Creating one now... \n"
    mkdir ~/$SDC_DOWNLOAD_DIR
    printf "\nDownloading SDC tarball and extracting...\n"
    wget -i ~/SDC --user=$SDC_DOWNLOAD_USER --password="${SDC_DOWNLOAD_PASSWORD}" ${STREAMSETS_DOWNLOAD_URL}/${SDC_VERSION}/tarball/streamsets-datacollector-all-${SDC_VERSION}.tgz
    mv streamsets-datacollector-all-${SDC_VERSION}.tgz ~/${SDC_DOWNLOAD_DIR}
    tar -xvf ~/$SDC_DOWNLOAD_DIR/streamsets-datacollector-all-${SDC_VERSION}.tgz -C ~/$SDC_DOWNLOAD_DIR
  else
    if [ ! -f /$HOME/$SDC_DOWNLOAD_DIR/streamsets-datacollector-all-${SDC_VERSION}.tgz ]
       then
            printf "\n SDC tarball not present. Downloading it now \n"
            # Download SDC tarball
            wget -i ~/SDC --user=$SDC_DOWNLOAD_USER --password="${SDC_DOWNLOAD_PASSWORD}" ${STREAMSETS_DOWNLOAD_URL}/${SDC_VERSION}/tarball/streamsets-datacollector-all-${SDC_VERSION}.tgz
	          mv streamsets-datacollector-all-${SDC_VERSION}.tgz ~/${SDC_DOWNLOAD_DIR}
            tar -xvf ~/$SDC_DOWNLOAD_DIR/streamsets-datacollector-all-${SDC_VERSION}.tgz -C ~/$SDC_DOWNLOAD_DIR
    fi
fi

# copy stage libs:
printf "\n Copying SDC stage libs to Docker volume \n"
sudo cp -R ~/SDC/streamsets-datacollector-$SDC_VERSION/streamsets-libs/* /var/lib/docker/volumes/$SDC_LIBS/_data

# launch the container
printf "\n Launching the SDC container \n"
docker run --network=cluster --restart on-failure -h sdc.cluster -p $SDC_PORT:$SDC_PORT --name $CONTAINER_NAME -d -P \
-e JAVA_HOME=/opt/java/openjdk -e SDC_JAVA_OPTS="-Djavax.net.ssl.trustStore=/etc/sdc/truststore.jks -Djavax.net.ssl.trustStorePassword=changeit -Xms1024m -Xmx1024m -server ${SDC_JAVA_OPTS}" \
-v /etc/ssl/certs/java/cacerts:/etc/sdc/truststore.jks \
-e STREAMSETS_LIBRARIES_EXTRA_DIR=/opt/sdc-extras \
--env SDC_CONF_http_authentication=form \
--mount source=$SDC_DATA,target=/data \
--mount source=$SDC_CONF,target=/etc/sdc \
--mount source=$SDC_LIBS,target=/opt/streamsets-datacollector-${SDC_VERSION}/streamsets-libs \
-v /home/ubuntu/JDBC/mysql-connector-java-8.0.23.jar:/opt/sdc-extras/streamsets-datacollector-jdbc-lib/lib/mysql-connector-java-8.0.23.jar:ro \
--volumes-from=$(docker create streamsets/datacollector-libs:streamsets-datacollector-jdbc-lib-${SDC_VERSION}-latest) \
--volumes-from=$(docker create streamsets/enterprise-datacollector-libs:streamsets-datacollector-greenplum-lib-1.1.0-latest) \
streamsets/datacollector:${SDC_VERSION}-latest

sudo sed -i 's/#sdc.base.http.url/sdc.base.http.url/g' /var/lib/docker/volumes/$SDC_CONF/_data/sdc.properties
sudo sed -i 's/=http/=https/g' /var/lib/docker/volumes/$SDC_CONF/_data/sdc.properties
sudo sed -i 's/<hostname>:<port>/sdc.cluster:'"$SDC_PORT"'/g' /var/lib/docker/volumes/$SDC_CONF/_data/sdc.properties
sudo sed -i 's/http.port=18630/http.port=-1/g' /var/lib/docker/volumes/$SDC_CONF/_data/sdc.properties
sudo sed -i 's/https.port=-1/https.port='"$SDC_PORT"'/g' /var/lib/docker/volumes/$SDC_CONF/_data/sdc.properties

printf "\n SDC available at : https://<hostname>:${SDC_PORT} \n"

# CLEAN UP
# docker stop <sdc-container>
# docker rm <sdc-container>
#docker volume rm  $SDC_CONF $SDC_DATA $SDC_LIBS

#Example:
#docker stop sdc-322
#docker rm sdc-322
#docker volume rm sdc-conf-3-22-0 sdc-data-3-22-0 sdc-stage-libs-3-22-0
