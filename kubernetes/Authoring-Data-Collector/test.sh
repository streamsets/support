
# Test download job
# echo $STREAMSETS_DOWNLOAD_URL
# echo $SDC_DOWNLOAD_USER
# echo $SDC_DOWNLOAD_PASSWORD
# echo $SDC_VERSION
# wget --user=$SDC_DOWNLOAD_USER --password="${SDC_DOWNLOAD_PASSWORD}" ${STREAMSETS_DOWNLOAD_URL}/${SDC_VERSION}/tarball/streamsets-datacollector-all-${SDC_VERSION}.tgz

BYellow='\033[1;33m' # Foreground BYellow
On_Yellow='\033[33;5;7m' #Backgroud BYellow
Color_Off='\033[0m' # No Color

# Some utility functions
i=1
spinner(){
  sp="/-\|"
  sleep 3
  printf "\b${sp:i++%${#sp}:1}"
}

cmdWait(){
  BACK_PID=$!
  wait $BACK_PID
}

log() {
    printf "\n${BYellow}$1${Color_Off}\n"
}

SCH_PASSWORD1=$SCH_PASSWORD
SDC_DOWNLOAD_PASSWORD1=$SDC_DOWNLOAD_PASSWORD
SCH_USER1=$SCH_USER



read -p 'SCH URL[https://cloud.streamsets.com]: ' SCH_URL
SCH_URL=${SCH_URL:-https://cloud.streamsets.com}

read -p 'SCH ORG[dpmsupport]:' SCH_ORG
SCH_ORG=${SCH_ORG:-dpmsupport}

read -p 'SCH USER: ' SCH_USER
SCH_USER=${SCH_USER:-$SCH_USER1}

read -sp 'SCH PASSWORD: ' SCH_PASSWORD
SCH_PASSWORD=${SCH_PASSWORD:-$SCH_PASSWORD1}
printf "\n"

read -p 'SDC DOWNLOAD USER[StreamSets]:' SDC_DOWNLOAD_USER
SDC_DOWNLOAD_USER=${SDC_DOWNLOAD_USER:-StreamSets}

read -sp 'SDC DOWNLOAD PASSWORD: ' SDC_DOWNLOAD_PASSWORD
SDC_DOWNLOAD_PASSWORD=${SDC_DOWNLOAD_PASSWORD:-$SDC_DOWNLOAD_PASSWORD1}
printf "\n"

read -p 'SDC VERSION: ' SDC_VERSION
SDC_VERSION=${SDC_VERSION:-$SDC_VERSION1}

read -p 'Installation Type(b -basic | f -full) [b]: ' INSTALL_TYPE
INSTALL_TYPE=${INSTALL_TYPE:-b}

read -p 'SDC LABEL: ' SDC_LABEL
SDC_LABEL=${SDC_LABEL:-$SDC_LABEL}

SCH_HOST=$(echo "$SCH_URL" | cut -c9-)
# Check prerequisites [ TO DO  - helm / kubectl / jq]


STREAMSETS_DOWNLOAD_URL=https://downloads.streamsets.com/datacollector
KUBE_NAMESPACE="sdc-$(echo "$SDC_VERSION" | tr . -)"
SDC_HOSTNAME=${USER}-${KUBE_NAMESPACE}

echo "SDC_HOSTNAME: $SDC_HOSTNAME"
echo "SDC_VERSION: $SDC_VERSION"
# Adding default label
if [ ! $SDC_LABEL == "" ]; then
  SDC_LABEL="${SDC_LABEL},${USER}-${KUBE_NAMESPACE}"
else
  SDC_LABEL=${USER}-${KUBE_NAMESPACE}
fi

# delete the GKE cluster if exists with the same name
if [[ $(gcloud container clusters list | awk 'FNR == 2 {print $1}') == $USER-$KUBE_NAMESPACE ]]; then
    printf "Creating GKE cluster $USER-$KUBE_NAMESPACE \n"
    log 'GKE cluster already exists. It will be deleted'
    while true; do
      read -p "Do you wish to proceed? " yn
      case $yn in
        [Yy]* ) gcloud container clusters delete $USER-$KUBE_NAMESPACE;
                break;;
        [Nn]* ) exit;;
        * ) echo "Please answer Y or N.";;
      esac
   done
fi
