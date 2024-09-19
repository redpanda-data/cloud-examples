#!/usr/bin/env bash

region=${REGION:-eastus}
dry_run=${DRY_RUN:-false}

subs_id=$1
if [ "$subs_id" != "" ]; then
    echo "Setting subscription: $subs_id ..."
    az account set --subscription $subs_id
fi

tenant_id=$(az account show --query tenantId -o tsv)

function prefix() {
   echo ${PREFIX:-"cli-"}$1
}

function run() {
   cmd=$1
   echo $cmd
   if [ "$dry_run" != "true" ]; then
       $cmd
   fi
}