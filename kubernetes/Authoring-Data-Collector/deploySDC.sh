#!/bin/bash

BYellow='\033[1;33m' # Foreground BYellow
On_Yellow='\033[33;5;7m' #Backgroud BYellow
Color_Off='\033[0m' # No Color


SCH_PASSWORD1=$SCH_PASSWORD
SDC_DOWNLOAD_PASSWORD1=$SDC_DOWNLOAD_PASSWORD
SCH_USER1=$SCH_USER


read -p 'SDC VERSION: ' SDC_VERSION
SDC_VERSION=${SDC_VERSION:-$SDC_VERSION1}

read -p 'SDC LABEL: ' SDC_LABEL
SDC_LABEL=${SDC_LABEL:-$SDC_LABEL}

read -p 'Need Provisioning Agent? (y/n) [n]: ' PROVISIONING_AGENT
PROVISIONING_AGENT=${PROVISIONING_AGENT:-n}

read -p 'Installation Type(b -basic | f -full) [b]: ' INSTALL_TYPE
INSTALL_TYPE=${INSTALL_TYPE:-b}

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




SCH_HOST=$(echo "$SCH_URL" | cut -c9-)

STREAMSETS_DOWNLOAD_URL=https://downloads.streamsets.com/datacollector
KUBE_NAMESPACE="sdc-$(echo "$SDC_VERSION" | tr . -)"
SDC_HOSTNAME=${USER}-${KUBE_NAMESPACE}

# Adding default label
if [ ! $SDC_LABEL == "" ]; then
  SDC_LABEL="${SDC_LABEL},${USER}-${KUBE_NAMESPACE}"
else
  SDC_LABEL=${USER}-${KUBE_NAMESPACE}
fi

echo "SDC_LABEL: ${USER}-${KUBE_NAMESPACE}"

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
    printf "\n${BYellow}$1${Color_Off} \n"
}

if [[ -z $SCH_USER  || -z $SCH_PASSWORD || -z $SDC_VERSION  || -z $SDC_DOWNLOAD_PASSWORD ]]
  then
      log 'Mandatory values not present'
      echo "SCH_USER: $SCH_USER"
      echo "SCH_PASSWORD: $SCH_PASSWORD"
      echo "SDC_VERSION: $SDC_VERSION"
      echo "SDC_DOWNLOAD_PASSWORD: $SDC_DOWNLOAD_PASSWORD"
      exit 1
fi

# Get auth token to interact with Control Hub
SCH_AUTH_TOKEN=$(curl -s -X POST -d "{\"userName\":\"${SCH_USER}\", \"password\": \"${SCH_PASSWORD}\"}" ${SCH_URL}/security/public-rest/v1/authentication/login --header "Content-Type:application/json" --header "X-Requested-By:SDC" -c - | sed -n '/SS-SSO-LOGIN/p' | perl -lane 'print $F[$#F]')

# check if the requested SDC version already exists
SDC_ID=$(curl -X GET ${SCH_URL}/jobrunner/rest/v1/sdcs\?executorType\=COLLECTOR\&label\=${USER}-${KUBE_NAMESPACE}\&organization\=${SCH_ORG} --header "Content-Type:application/json" --header "X-Requested-By:SDC" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:${SCH_AUTH_TOKEN}" |  jq -r '.[].id')
if [ ! $SDC_ID == "" ]; then
  echo "[\"$SDC_ID\"]" > sdc.id
  log 'Requested SDC version already registered with this ControlHub'
  log 'Registered SDC will be removed from ControlHub'
  while true; do
    read -p "Do you wish to proceed by? : " yn
    printf "\r"
    case $yn in
      [Yy]* ) curl -s -X POST -d "@sdc.id"  ${SCH_URL}/security/rest/v1/organization/${SCH_ORG}/components/deactivate --header "Content-Type:application/json" --header "X-Requested-By:SCH" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:${SCH_AUTH_TOKEN}"
              curl -s -X POST -d "@sdc.id"  ${SCH_URL}/security/rest/v1/organization/${SCH_ORG}/components/delete --header "Content-Type:application/json" --header "X-Requested-By:SCH" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:${SCH_AUTH_TOKEN}"
              curl -s -X POST -d "@sdc.id"  ${SCH_URL}/jobrunner/rest/v1/sdcs/delete --header "Content-Type:application/json" --header "X-Requested-By:SCH" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:${SCH_AUTH_TOKEN}"
              printf "SDC \'$SDC_HOSTNAME\' deleted and unregistered from ControlHub\n"
              rm sdc.id
              break;;
      [Nn]* ) exit;;
      * ) echo "Please answer Y or N.";;
    esac
  done
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

# create the Kubernetes cluster on GKE
gcloud container clusters create $USER-$KUBE_NAMESPACE \
    --num-nodes=1 \
    --machine-type=e2-standard-2 \
    --zone=us-central1-c
printf "$USER-$KUBE_NAMESPACE cluster created  \n"

if [[ $(gcloud container clusters list | grep $USER-$KUBE_NAMESPACE | awk 'FNR == 1 {print $1}') == "" ]]
  then
    printf "Failed to create the Kubernetes cluster !! \n"
    exit 0;
fi
# create a namespace to isolate all the resources for this deployment
kubectl create namespace $KUBE_NAMESPACE

# validate namespace
if [[ $(kubectl get namespaces $KUBE_NAMESPACE | awk 'FNR == 2 {print $1}') != $KUBE_NAMESPACE ]]
  then
    printf "Failed to create the Kubernetes namespace !! \n"
    exit 0;
  else
    kubectl config set-context --current --namespace $KUBE_NAMESPACE
    if [[ $(kubectl config view --minify | grep namespace | awk '{print $2}') != $KUBE_NAMESPACE ]]
      then
        printf "Failed to set context to $KUBE_NAMESPACE namespace !! \n"
    fi
fi

# Generate ssl key-pair to enable SSL for the SDC:
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout sdc.key -out sdc.crt -subj "/CN=$USER-auth-sdc/O=$USER-auth-sdc"

# Store the cert in a k8's secret
kubectl create secret generic sdc-tls --namespace=${KUBE_NAMESPACE} \
    --from-file=sdc.crt \
    --from-file=sdc.key

# create configmap for environment variables
kubectl create configmap sdc-deployment-config \
 --from-literal SCH_URL=$SCH_URL \
 --from-literal SCH_ORG=$SCH_ORG \
 --from-literal SCH_USER=$SCH_USER \
 --from-literal SDC_DOWNLOAD_USER=$SDC_DOWNLOAD_USER \
 --from-literal SDC_VERSION=$SDC_VERSION \
 --from-literal STREAMSETS_DOWNLOAD_URL=$STREAMSETS_DOWNLOAD_URL

# Create secrets to secure the passwords
 kubectl create secret generic sdc-deployment-secret \
  --from-literal SCH_PASSWORD=$SCH_PASSWORD \
  --from-literal SDC_DOWNLOAD_PASSWORD="${SDC_DOWNLOAD_PASSWORD}"

#### Create a lower-cased UUID and store it in a secret
    SDC_ID=`uuidgen | tr "[:upper:]" "[:lower:]"`
    echo "Generated sdc.id "${SDC_ID}
    kubectl create secret generic sdc-id --from-literal=sdc.id=${SDC_ID}

# Get an SDC auth token from Control Hub
SDC_AUTH_TOKEN=$(curl -s -X PUT -d "{\"organization\": \"${SCH_ORG}\", \"componentType\" : \"dc\", \"numberOfComponents\" : 1, \"active\" : true}" ${SCH_URL}/security/rest/v1/organization/${SCH_ORG}/components --header "Content-Type:application/json" --header "X-Requested-By:SDC" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:${SCH_AUTH_TOKEN}" | jq '.[0].fullAuthToken')

  if [ -z "$SDC_AUTH_TOKEN" ]; then
    log "Failed to generate SDC token. Please ensure SCH credentials are correct and have correct permissions"
    exit 1
  fi
  echo "Generated an Auth Token for SDC"

# Store the SDC auth token in a secret
kubectl create secret generic sdc-auth-token --from-literal=application-token.txt=${SDC_AUTH_TOKEN}

if [ $PROVISIONING_AGENT == "y" ]; then

      ## Use the auth token to get a token for a Control Agent
      AGENT_TOKEN=$(curl -s -X PUT -d "{\"organization\": \"${SCH_ORG}\", \"componentType\" : \"provisioning-agent\", \"numberOfComponents\" : 1, \"active\" : true}" ${SCH_URL}/security/rest/v1/organization/${SCH_ORG}/components --header "Content-Type:application/json" --header "X-Requested-By:SDC" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:${SCH_AUTH_TOKEN}" | jq '.[0].fullAuthToken')

      if [ -z "$AGENT_TOKEN" ]; then
        echo "Error: Failed to generate control agent token."
        echo "Please verify you have Provisioning Operator permissions in SCH"
        exit 1
      fi

      ## Store the Control Agent token in a secret
      kubectl create secret generic control-agent-token \
          --from-literal=dpm_agent_token_string=${AGENT_TOKEN}

      ## Create a secret for the Control Agent to use
      kubectl create secret generic control-agent-secret

      ## Generate a UUID for the Control Agent
      AGENT_ID=$(uuidgen)

      ## Store connection properties in a configmap for the Control Agent
      kubectl create configmap control-agent-config \
          --from-literal=org=${SCH_ORG} \
          --from-literal=sch_url=${SCH_URL} \
          --from-literal=agent_id=${AGENT_ID}

      ## Create a Service Account to run the Control Agent
      kubectl create -f yaml/control-agent-rbac.yaml

      ## Deploy the Control Agent
      sed -i -e  's/sanju/'"$USER"'/' yaml/control-agent.yaml
      kubectl create -f yaml/control-agent.yaml
      sed -i -e  's/'"$USER"'/sanju/' yaml/control-agent.yaml
fi

# install NGINX ingress controller
helm install $KUBE_NAMESPACE stable/nginx-ingress --set rbac.create=true --set controller.publishService.enabled=true --namespace=$KUBE_NAMESPACE

if [[ "$INSTALL_TYPE" == "f" ]]
  then
      #  Create the Volume to store SDC stagelibs.
      kubectl apply -f yaml/sdc-pvc.yaml
      #  Run a Job to download all the stagelibs and populate the K8's volume
      kubectl apply -f yaml/sdcDownloadJob.yaml

      # Allow time to create Container
      while [[ $(kubectl get pods | awk 'FNR == 5 {print $3}') == "ContainerCreating" ]]; do
        spinner
      done
      printf "Please wait for the stage libs to download................"
      # Wait until the job is completed
      # stage lib download could fail sometimes potentially due https://github.com/kubernetes/kubernetes/issues/76790
      while [ $(kubectl get jobs sdc-stage-libs-job | awk 'FNR == 2 {print $2}') == "0/1" ]; do
        spinner
      done
      printf "\n"
      # update DPM specs with SCH URL and DC labels
      sed -i -e  's/sch-url/'"$SCH_HOST"'/' yaml/dpm_ConfigMap.yaml
      sed -i -e  's/auth-sdc/'"$SDC_LABEL"'/' yaml/dpm_ConfigMap.yaml

      #### Deploy ConfigMap for dpm.properties
      kubectl apply -f yaml/dpm_ConfigMap.yaml

      # reset DPM specs with dummy SCH URL and labels
      sed -i -e  's/'"$SCH_HOST"'/sch-url/' yaml/dpm_ConfigMap.yaml
      sed -i -e  's/'"$SDC_LABEL"'/auth-sdc/' yaml/dpm_ConfigMap.yaml

      # update SDC specs with $SDC_VERSION and to have SDC hostanme start with the username
      sed -i -e  's/latest/'"$SDC_VERSION"'/' yaml/sdcFullDeployment.yaml
      sed -i -e  's/sanju-auth-sdc/'"$SDC_HOSTNAME"'/' yaml/sdcFullDeployment.yaml

      # Deploy the SDC pod
      kubectl apply -f yaml/sdcFullDeployment.yaml &
      cmdWait

      # Reset the specs with the defaults for next run
      sed -i -e  's/'"$SDC_VERSION"'/latest/' yaml/sdcFullDeployment.yaml
      sed -i -e  's/'"$USER"'-sdc-latest/sanju-auth-sdc/' yaml/sdcFullDeployment.yaml
  else
      # update DPM specs with SCH URL and DC labels
      sed -i -e  's/sch-url/'"$SCH_HOST"'/' yaml/dpm_ConfigMap.yaml
      sed -i -e  's/auth-sdc/'"$SDC_LABEL"'/' yaml/dpm_ConfigMap.yaml

      #### Deploy ConfigMap for dpm.properties
      kubectl apply -f yaml/dpm_ConfigMap.yaml

      # reset DPM specs with dummy SCH URL and labels
      sed -i -e  's/'"$SCH_HOST"'/sch-url/' yaml/dpm_ConfigMap.yaml
      sed -i -e  's/'"$SDC_LABEL"'/auth-sdc/' yaml/dpm_ConfigMap.yaml

      # update SDC specs with $SDC_VERSION and to have SDC hostanme start with the username
      sed -i -e  's/latest/'"$SDC_VERSION"'/' yaml/sdcDeployment.yaml
      sed -i -e  's/sanju-auth-sdc/'"$SDC_HOSTNAME"'/' yaml/sdcDeployment.yaml

      # Deploy the SDC pod
      kubectl apply -f yaml/sdcDeployment.yaml &
      cmdWait

      # Reset the specs with the defaults for next run
      sed -i -e  's/'"$SDC_VERSION"'/latest/' yaml/sdcDeployment.yaml
      sed -i -e  's/'"$USER"'-sdc-latest/sanju-auth-sdc/' yaml/sdcDeployment.yaml
fi

printf "Please wait for the pods to come online................"
while [[ $(kubectl get deployments.apps auth-sdc | awk 'FNR == 2 {print $2}') == "0/1" ]]; do
  spinner
done

# Wait for the LoadBalancer IP to be available
while [[ $(kubectl describe ingress sdc | awk 'FNR == 3 {print $2}' | awk '{print length}') -le 10 ]]; do
  spinner
done

SDC_IP=$(kubectl get ingress sdc | awk 'FNR == 2 {print $4}')
printf "\n"

log 'You will be prompted to enter your root/admin password to update the host file'
printf "\r"
sudo bash -c "sed -i -e '/'"$KUBE_NAMESPACE"'/d' /etc/hosts"
printf "\r"

sudo bash -c "sed -i -e '/deploySDC.sh/d' /etc/hosts"
sudo bash -c "echo  \# Added by deploySDC.sh on $(date)  >> /etc/hosts"
sudo bash -c "echo  $SDC_IP  $SDC_HOSTNAME  >> /etc/hosts"
printf "\nUpdated /etc/hosts file with the SDC URL"
printf "\nHit https://$SDC_HOSTNAME/sdc/ in the browser to get started !!"

# CLEAN UP
rm sdc.crt sdc.key
log ' $$$ PLEASE REMEMBER TO DELETE THE CLUSTER AFTER USING $$$ '
printf "gcloud container clusters delete $USER-$KUBE_NAMESPACE\n"
