#!/usr/bin/env bash

set -e

. ./set_env.sh $1

op="create --location $region"
opts="--address-prefixes 10.0.0.0/20"
if [ "$(basename $0)" = "delete_network.sh" ]; then
   op="delete"
   opts=""
fi

network_rg=$(prefix ${RP_NETWORK_RESOURCE_GROUP_NAME:-"network-rg"})

# create vnet
vnet_name=$(prefix ${RP_VNET_NAME:-"rp-vnet"})
run "az network vnet $op --name $vnet_name --resource-group $network_rg $opts"

