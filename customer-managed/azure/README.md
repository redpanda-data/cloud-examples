# Overview

This repository contains the code that deploys the resources customers are responsible for creating in association with a Redpanda customer-managed Azure cluster.
These resources should be created in advance by the customer and then provided to Redpanda during cluster creation.
The code is provided in [Terraform](https://developer.hashicorp.com/terraform) and Azure CLI (TODO).

> There may be resources in this repository that already exist within your environment (for example, the VNET) that you don't want to create. Variables are provided for this purpose.

# Customer Managed Resources
Customer Managed Resources can be broken down into the following groups. You can walk through the code to get the exact list of the resources required to create and deploy Redpanda cluster.
- Resource Group Resources
- User Assigned Identities
- IAM Roles and Assignments
- Network
- Storage
- Key Vaults

# Deploy Customer Managed Resources With Terraform
## Prerequisites

1. Access to an Azure subscription where you want to create your cluster.
2. Knowledge of your internal VNET and subnet configuration.
3. Permission to create, modify, and delete the resources described by this Terraform.
4. [Terraform](https://developer.hashicorp.com/terraform/install) version 1.8.5 or later.

## Setup

> You may want to configure [remote state](https://developer.hashicorp.com/terraform/language/state/remote) for this
> Terraform. For simplicity, these instructions assume local state.

### Configure The Variables

The variable files contain the variables that allow you to modify to meet your specific needs.
- `vars.azure.tf`:  It contains the variables related to Azure credentials.
- `vars.condition.tf`: It contains the conditional variables on whether to e.g. create NAT.
- `vars.customer_input.tf`: It contains the variables needed for creating a cluster, which are required when using the Cloud API to create one.
- `vars.iam.tf`: It contains the variables related to IAM roles.
- `vars.misc.tf`: It contains the variables, region, zones, tags and resource name prefix.

You can get the description of each variable in [here](./terraform/README.md).

Create a JSON file called `byovnet.auto.tfvars.json` inside the Terraform directory.

```shell
{
  "azure_tenant_id": "",
  "azure_subscription_id": "",
  "region": "",
  "resource_name_prefix": "",
  "tags": {},
  "redpanda_resource_group_name": "",
  "redpanda_storage_resource_group_name": "",
  "redpanda_network_resource_group_name": "",
  "redpanda_iam_resource_group_name": "",
  "redpanda_agent_identity_name": "",
  "redpanda_external_dns_identity_name": "",
  "redpanda_cluster_identity_name": "",
  "aks_identity_name": "",
  "redpanda_console_identity_name": "",
  "kafka_connect_identity_name": "",
  "redpanda_management_storage_account_name": "",
  "redpanda_management_storage_container_name": "",
  "redpanda_tiered_storage_account_name": "",
  "redpanda_tiered_storage_container_name": "",
  "redpanda_management_key_vault_name": "",
  "redpanda_console_key_vault_name": "",
  "vnet_name": "",
  "vnet_addresses": "10.0.0.0/20",
  "private_subnets": {},
  "egress_subnets": {},
  "reserved_subnet_cidrs": {},
  "redpanda_security_group_name": ""
}
```

### Initialize The Terraform

Initialize the working directory containing Terraform configuration files.

```shell
terraform init
```

## Apply The Terraform

```shell
terraform apply
```

### Capture The Output

The output of `terraform apply` should display a number of output values. For example:

```shell
agent_private_subnet_name = "my-snet-agent-private"
agent_user_assigned_identity_name = "my-agent-uai"
aks_user_assigned_identity_name = "my-aks-uai"
cert_manager_user_assigned_identity_name = "my-cert-manager-uai"
cluster_user_assigned_identity_name = "my-cluster-uai"
console_key_vault_name = "my-consolevault"
console_user_assigned_identity_name = "my-console-uai"
egress_subnet_name = "my-snet-agent-public"
external_dns_user_assigned_identity_name = "my-external-dns-uai"
iam_resource_group_name = "my-iam-rg"
kafka_connect_pods_subnet_name = "my-snet-kafka-connect-pods"
kafka_connect_user_assigned_identity_name = "my-kafka-connect-uai"
kafka_connect_vnet_subnet_name = "my-snet-kafka-connect-vnet"
management_bucket_storage_account_name = "mymanagement"
management_bucket_storage_container_name = "mymanagement"
management_key_vault_name = "my-redpandavault"
network_resource_group_name = "my-network-rg"
......
redpanda_resource_group_name = "my-redpanda-rg"
redpanda_security_group_name = "my-redpanda-nsg"
......
rp_0_pods_subnet_name = "my-snet-rp-0-pods"
rp_0_vnet_subnet_name = "my-snet-rp-0-vnet"
rp_1_pods_subnet_name = "my-snet-rp-1-pods"
rp_1_vnet_subnet_name = "my-snet-rp-1-vnet"
rp_2_pods_subnet_name = "my-snet-rp-2-pods"
rp_2_vnet_subnet_name = "my-snet-rp-2-vnet"
rp_connect_pods_subnet_name = "my-snet-connect-pods"
rp_connect_vnet_subnet_name = "my-snet-connect-vnet"
......
storage_resource_group_name = "my-storage-rg"
system_pods_subnet_name = "my-snet-system-pods"
system_vnet_subnet_name = "my-snet-system-vnet"
tiered_storage_account_name = "mytieredstorage"
tiered_storage_container_name = "mytieredstorage"
......
vnet_name = "my-rp-vnet"
```

These values can also be retrieved at any time by running `terraform output`.

Note these values. They are needed for the next steps. To continue with cluster creation, see [Create Azure BYO VNET Redpanda Cluster](#create-azure-byo-vnet-redpanda-cluster)

# Deploy Customer Managed Resource With Azure CLI
TODO

# Create Azure Redpanda Cluster With Customer Managed Resources (BYO VNET)
## Prerequisites

1. Access to an Azure subscription where you want to create your cluster.
2. Permission to call the [Redpanda Cloud API](https://docs.redpanda.com/redpanda-cloud/manage/api/cloud-api-quickstart/#try-the-cloud-api).
3. The customer managed resources have been created.

## Create Redpanda Network
You need to create a network with the POST body before creating Redpanda cluster. Replace the variables with the actual values.
Follow [here](https://docs.redpanda.com/redpanda-cloud/manage/api/cloud-api-quickstart/#try-the-cloud-api) to create a Redpanda resource group and bearer token.

```shell
export CLUSTER_NAME=mycluster
export RP_RESOURCE_GROUP=4997057a-9cb9-4920-a777-544eae848480
network_post_body=$(terraform show --json | jq --arg cluster_name "$CLUSTER_NAME" --arg rg_id "$RP_RESOURCE_GROUP" '{
  "cloud_provider": "CLOUD_PROVIDER_AZURE",
  "cluster_type": "TYPE_BYOC",
  "name": $cluster_name,
  "resource_group_id": $rg_id,
  "region": .values.outputs.region.value,
  "customer_managed_resources": {
    "azure": {
      "management_bucket": {
        "storage_account_name": .values.outputs.management_bucket_storage_account_name.value,
        "storage_container_name": .values.outputs.management_bucket_storage_container_name.value,
        "resource_group": { "name": .values.outputs.redpanda_resource_group_name.value }
      },
      "vnet": {
        "name": .values.outputs.vnet_name.value,
        "resource_group": { "name": .values.outputs.network_resource_group_name.value }
      },
      "subnets": {
        "rp_0_pods": { "name": .values.outputs.rp_0_pods_subnet_name.value },
        "rp_0_vnet": { "name": .values.outputs.rp_0_vnet_subnet_name.value },
        "rp_1_pods": { "name": .values.outputs.rp_1_pods_subnet_name.value },
        "rp_1_vnet": { "name": .values.outputs.rp_1_vnet_subnet_name.value },
        "rp_2_pods": { "name": .values.outputs.rp_2_pods_subnet_name.value },
        "rp_2_vnet": { "name": .values.outputs.rp_2_vnet_subnet_name.value },
        "rp_connect_pods": { "name": .values.outputs.rp_connect_pods_subnet_name.value },
        "rp_connect_vnet": { "name": .values.outputs.rp_connect_vnet_subnet_name.value },
        "kafka_connect_pods": { "name": .values.outputs.kafka_connect_pods_subnet_name.value },
        "kafka_connect_vnet": { "name": .values.outputs.kafka_connect_vnet_subnet_name.value },
        "sys_pods": { "name": .values.outputs.system_pods_subnet_name.value },
        "sys_vnet": { "name": .values.outputs.system_vnet_subnet_name.value },
        "rp_agent": { "name": .values.outputs.agent_private_subnet_name.value },
        "rp_egress_vnet": { "name": .values.outputs.egress_subnet_name.value }
      }
    }
  }
}')
```

Make Cloud API call to create a Redpanda network and get the network ID from the response in JSON `.operation.metadata.network_id`.

```shell
output=$(curl -vv -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d "$network_post_body" $PUBLIC_API_ENDPOINT/v1beta2/networks)

export NETWORK_ID=$(echo $output | jq ".resource_id")

```

## Create Redpanda Cluster
You need a network ID to create a Redpanda cluster. 
Follow [here](https://docs.redpanda.com/redpanda-cloud/manage/api/cloud-api-quickstart/#try-the-cloud-api) to create a resource group and bearer token.

```shell
export CLUSTER_NAME=mycluster
export RP_RESOURCE_GROUP=4997057a-9cb9-4920-a777-544eae848480
export NETWORK_ID=cuegs56k7gk1qa7nu7jg
export TIER=tier-1-azure-beta

cluster_post_body=$(terraform show --json | jq --arg cluster_name "$CLUSTER_NAME" \
  --arg namespace_id "$RP_RESOURCE_GROUP" \
  --arg network_id "$NETWORK_ID" \
  --arg tier "$TIER" \
  '{
  "cloud_provider": "CLOUD_PROVIDER_AZURE",
  "connection_type": "CONNECTION_TYPE_PUBLIC",
  "name": $cluster_name,
  "resource_group_id": $namespace_id,
  "network_id": $network_id,
  "region": .values.outputs.region.value,
  "zones": .values.outputs.zones.value,
  "throughput_tier": $tier,
  "type": "TYPE_BYOC",
  "customer_managed_resources": {
    "azure": {
      "cidrs": {
        "aks_service_cidr": (.values.outputs.networks.value | fromjson | ."subnet-cidrs-aks"."k8s-service")
      },
      "key_vaults": {
        "console_vault": { "name": .values.outputs.console_key_vault_name.value },
        "management_vault": { "name": .values.outputs.management_key_vault_name.value }
      },
      "resource_groups": {
        "iam_resource_group": { "name": .values.outputs.iam_resource_group_name.value },
        "redpanda_resource_group": { "name": .values.outputs.redpanda_resource_group_name.value },
        "storage_resource_group": { "name": .values.outputs.storage_resource_group_name.value }
      },
      "security_groups": {
        "redpanda_security_group": { "name": .values.outputs.redpanda_security_group_name.value }
      },
      "tiered_cloud_storage": {
        "storage_account_name": .values.outputs.tiered_storage_account_name.value,
        "storage_container_name": .values.outputs.tiered_storage_container_name.value
      },
      "user_assigned_identities": {
        "agent_user_assigned_identity": { "name": .values.outputs.agent_user_assigned_identity_name.value },
        "aks_user_assigned_identity": { "name": .values.outputs.aks_user_assigned_identity_name.value },
        "cert_manager_assigned_identity": { "name": .values.outputs.cert_manager_user_assigned_identity_name.value },
        "external_dns_assigned_identity": { "name": .values.outputs.external_dns_user_assigned_identity_name.value },
        "redpanda_cluster_assigned_identity": { "name": .values.outputs.cluster_user_assigned_identity_name.value },
        "redpanda_console_assigned_identity": { "name": .values.outputs.console_user_assigned_identity_name.value },
        "kafka_connect_assigned_identity": { "name": .values.outputs.kafka_connect_user_assigned_identity_name.value }
      }
    }
  }
}')
```

Make Cloud API call to create a Redpanda network and get the network ID from the response in JSON `.operation.metadata.cluster_id`.

```shell
curl -vv -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $token" \
  -d "$cluster_post_body" $PUBLIC_API_ENDPOINT/v1beta2/clusters
```

## Deploy Cluster
After getting a Redpanda cluster ID in the previous step, you deploy the cluster with `rpk` by replacing `$rp_id` and `$subscription_id` with the actual values.
```shell
rpk cloud byoc azure apply --redpanda-id='$rp_id' --subscription-id='$subscription_id'
```

## Check The Status of Cluster Deployment
You can go to the [Repanda Cloud UI](https://cloud.redpanda.com) to check the progress of the cluster deployment.