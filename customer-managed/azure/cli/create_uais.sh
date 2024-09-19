#!/usr/bin/env bash

set -e

. ./set_env.sh $1

op="create"
if [ "$(basename $0)" = "delete_uais.sh" ]; then
   op="delete"
fi

iam_rg=$(prefix ${RP_IAM_RESOURCE_GROUP_NAME:-"iam-rg"})

agent_uai=$(prefix ${RP_AGENT_UAI_NAME:-"agent-uai"})
external_dns_uai=$(prefix ${RP_EXTERNAL_DNS_UAI_NAME:-"external-dns-uai"})
cert_managers_uai=$(prefix ${RP_CERT_MANAGER_UAI_NAME:-"cert-manager-uai"})
console_uai=$(prefix ${RP_CONSOLE_UAI_NAME:-"console-uai"})
aks_uai=$(prefix ${RP_AKS_UAI_NAME:-"aks-uai"})
cluster_uai=$(prefix ${RP_CLUSTER_UAI_NAME:-"cluster-uai"})

for uai in $agent_uai $external_dns_uai $cert_manager_uai $console_uai $aks_uai $cluster_uai
do
   run "az identity $op --name $uai --resource-group $iam_rg"
done

