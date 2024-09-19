#!/usr/bin/env bash

set -e

. ./set_env.sh $1

op="create --enabled-for-deployment true --enabled-for-template-deployment true --enabled-for-disk-encryption true --enable-purge-protection true --enable-rbac-authorization true --public-network-access Enabled --sku standard"
if [ "$(basename $0)" = "delete_key_vaults.sh" ]; then
   op="delete"
fi

rp_rg=$(prefix ${RP_RESOURCE_GROUP_NAME:-"rp-rg"})

rp_vault=$(prefix ${RP_VAULT_NAME:-"redpandavault"})
console_vault=$(prefix ${RP_CONSOLE_VAULT_NAME:-"consolevault"})

for vault in $rp_vault $console_vault
do
   run "az keyvault $op --name $vault --resource-group $rp_rg"
done

if [ "$op" = "delete" ]; then
   exit 0
fi

# update tenant_id in key vault
run "az keyvault update --name $rp_vault --resource-group $rp_rg --set properties.tenantId=$tenant_id"
run "az keyvault update --name $console_vault --resource-group $rp_rg --set properties.tenantId=$tenant_id"

# update network acl in key vault to bypass Azure services and allow all networks
# update ACL to suit your needs
run "az keyvault network-rule add --name $rp_vault --resource-group $rp_rg --ip-address 0.0.0.0/0"
run "az keyvault network-rule add --name $console_vault --resource-group $rp_rg --ip-address 0.0.0.0/0"

# bypass Azure services
run "az keyvault network-rule add --name $rp_vault --resource-group $rp_rg --bypass AzureServices"
run "az keyvault network-rule add --name $console_vault --resource-group $rp_rg --bypass AzureServices"

# default action is to allow all traffic
# run "az keyvault network-rule add --name $rp_vault --resource-group $rp_rg --default-action Allow"
# run az keyvault network-rule add --name $console_vault --resource-group $rp_rg --default-action Allow"

# set access policy for key vault
run "az keyvault set-policy --name $rp_vault --resource-group $rp_rg --secret-permissions get set list delete purge recover backup restore"
run "az keyvault set-policy --name $console_vault --resource-group $rp_rg --secret-permissions get set list delete purge recover backup restore"
