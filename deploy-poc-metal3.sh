#!/usr/bin/env bash

source deploy-poc-common.sh

echo -e "${GREEN}Install CAPM3 CRDs${NOCOLOR}"

oc create -f crds/capm3-crds.yaml

echo -e "${GREEN}Configure BMO to watchAllNamespaces${NOCOLOR}"

oc get provisioning/provisioning-configuration -o json | jq '.spec += {watchAllNamespaces: true}' | oc apply -f -

echo -e "${GREEN}Create BMH resources${NOCOLOR}"
pushd ${SCRIPTDIR}
sed -i "s/namespace:.*/namespace: ${NAMESPACE}/" ocp/${CLUSTER_NAME}/extra_host_manifests.yaml
oc apply -f ocp/${CLUSTER_NAME}/extra_host_manifests.yaml
popd

echo -e "${GREEN}Run the operator${NOCOLOR}"

oc apply -f operator/operator.yaml

echo -e "${GREEN}Create CAPI resources: CAPIDeployment, MachineSet, Metal3MachineTemplate${NOCOLOR}"

export NAMESPACE="ocp-cluster-api"
export API_ENDPOINT_PORT="6443"
export IMAGE_CHECKSUM_TYPE="sha256"
export IMAGE_FORMAT="qcow2"
export NODE_DRAIN_TIMEOUT="0s"

export API_ENDPOINT_HOST=$(oc get infrastructure/cluster -o json | jq ".status.platformStatus.baremetal.apiServerInternalIP")

pushd ${SCRIPTDIR}
source common.sh
source network.sh
source utils.sh
source ocp_install_env.sh
source rhcos.sh
set +x
set +e
popd
export KUBERNETES_VERSION=$(oc version -o json | jq ".serverVersion.gitVersion")
export POD_CIDR=${CLUSTER_SUBNET_V4}
export SERVICE_CIDR=${SERVICE_SUBNET_V4}
export IMAGE_URL=http://$MIRROR_IP/images/${MACHINE_OS_IMAGE_NAME}
export IMAGE_CHECKSUM=http://$MIRROR_IP/images/${MACHINE_OS_IMAGE_NAME}.sha256sum
export WORKER_MACHINE_COUNT=$NUM_EXTRA_WORKERS

envsubst < examples/capm3-resources.yaml | oc apply -f -
