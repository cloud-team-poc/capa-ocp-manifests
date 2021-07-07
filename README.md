# POC for running CAPI on OpenShift

## Running on AWS

Set following environmental variables:

```
export KUBECONFIG=<path-to-kubeconfig>
```

Edit `AWSMachineTemplate`(equivalent to ProviderSpec in MachineAPI) in `examples/capa-resources.yaml`.
Replace `iamInstanceProfile, ami, subnet, additionalSecurityGroups` with your values(this step is normally done by installer in MAPI). You can pick this values from providerSpec of MAPI worker machine(`oc get machine -n openshift-machine-api`).

Run `deploy-poc-aws.sh` script.

## Running on Metal3

Run https://github.com/openshift-metal3/dev-scripts with the following:

```
export NUM_WORKERS=0
export NUM_EXTRA_WORKERS=2
export APPLY_EXTRA_WORKERS=false
```

Set 'SCRIPTDIR' to your dev script dir, then run `deploy-poc-metal3.sh` script.
```
export SCRIPTDIR=/opt/dev-scripts
./deploy-poc-metal3.sh
```

Then run the metal3 branch for cluster-patch
This sets the cluster.status = ready
```
git clone git@github.com:asalkeld/cluster-patch.git
git checkout -b metal3 origin/metal3
cd cluster-patch
go run ./main.go -clusterName $CLUSTER_NAME -kubeconfig $KUBECONFIG
```
