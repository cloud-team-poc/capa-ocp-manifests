#!/usr/bin/env bash

GREEN='\033[0;32m'
NOCOLOR='\033[0m'

echo -e "${GREEN}Downscale CVO${NOCOLOR}"

oc scale deployment cluster-version-operator -nopenshift-cluster-version --replicas=0

echo -e "${GREEN}Install patched cluster machine approver${NOCOLOR}"

oc delete deployment -n openshift-cluster-machine-approver --all

oc create -f cluster-machine-approver/deployment.yaml

echo -e "${GREEN}Install CAPI CRDs${NOCOLOR}"

oc create -f crds/capi-crds.yaml
oc create -f https://raw.githubusercontent.com/cloud-team-poc/openshift-cluster-api-operator/master/config/crd/bases/capi.openshift.io_capideployments.yaml

echo -e "${GREEN}Create worker user data for CAPI${NOCOLOR}"

oc create namespace ocp-cluster-api

USERDATA=$(oc get secret worker-user-data -n openshift-machine-api -o json | jq -r ".data.userData" | base64 --decode)
oc create secret generic worker-user-data -n ocp-cluster-api --from-literal=value=$USERDATA
unset USERDATA

echo -e "${GREEN}Create kubeconfig for CAPI cluster${NOCOLOR}"

oc create secret generic capi-poc-kubeconfig -n ocp-cluster-api --from-file=value=$KUBECONFIG
