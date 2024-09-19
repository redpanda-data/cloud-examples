#!/usr/bin/env bash

set -e

. ./set_env.sh $1

op="create --location $region"
if [ "$(basename $0)" = "delete_resource_groups.sh" ]; then
   op="delete --yes --no-wait"
fi

rp_rg=$(prefix ${RP_RESOURCE_GROUP_NAME:-"redpanda-rg"})
network_rg=$(prefix ${RP_NETWORK_RESOURCE_GROUP_NAME:-"network-rg"})
storage_rg=$(prefix ${RP_STORAGE_RESOURCE_GROUP_NAME:-"storage-rg"})
iam_rg=$(prefix ${RP_IAM_RESOURCE_GROUP_NAME:-"iam-rg"})

for rg in $rp_rg $network_rg $storage_rg $iam_rg
do
   run "az group $op --name $rg"
done

