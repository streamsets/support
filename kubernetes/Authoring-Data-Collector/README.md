<img src="/images/readme.png" align="right" />

# Authoring Data Collector on GKE cluster

This script automates creating a GKE cluster with authoring SDC (with all the stage libs)

# GKE cluster specs:

Machine name	   e2-standard-2
vCPUs            2
Memory (GB)     8


## Pre-req:

1) Google CLI -- https://cloud.google.com/sdk/docs/quickstart
2) kubectl (brew install kubectl )
3) jq (brew install jq)
4) helm (brew install helm)

## Optional (recommended)

For minimal interaction with the script, you should set the following environment variables:

1) SCH_URL (default: https://cloud.streamsets.com)

2) SCH_ORG (default: dpmsupport)

3) SCH_USER (Your SCH user) ** Please note: https://streamsets.com/documentation/controlhub/latest/help/controlhub/UserGuide/OrganizationSecurity/Authentication.html#concept_nmk_zh3_11b

4) SCH_PASSWORD (Your SCH password)

5) SDC_DOWNLOAD_USER (default: StreamSets)

6) SDC_DOWNLOAD_PASSWORD - Get the latest password @ https://support.streamsets.com/hc/en-us/articles/360046575233-StreamSets-Data-Collector-and-Transformer-Binaries-Download

7) INSTALL_TYPE (default: b(basic), specify 'f' to load all stage libraries)

## CLEANUP

The script provide the options to:
a)  Delete and un-register a previously created SDC with the same VERSION
b)  Delete a previously created GKE cluster for the requested VERSION

It's your responsibility to delete the GKE cluster after using.

## Known issues

1) When prompted for the password to update the /etc/hosts file, the first attempt fails. Seems there
