#!/usr/bin/env bash

source deploy-poc-common.sh

echo -e "${GREEN}Install CAPA CRDs${NOCOLOR}"

oc create -f crds/capa-crds.yaml

echo -e "${GREEN}Create namespace and run operator${NOCOLOR}"

oc create -f operator/operator.yaml

echo -e "${GREEN}Create CAPI resources: CAPIDeployment, MachineSet, AWSMachineTemplate${NOCOLOR}"

oc apply -f examples/capa-resources.yaml
