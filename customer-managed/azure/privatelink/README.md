# Redpanda Azure private link


### Getting Started

#### Required tools:
- rpk
- terraform
- Azure CLI
- Curl
- jq

Once all tools are installed make sure you have logged into to the azure CLI

```
az login
```

## Provisioning Redpanda with Private Link

To provision a private Redpanda cluster with Private Link you must use the API. UI support is coming soon.

### Environment setup

1. To start set the following env variables:
    ```
    export API_ENDPOINT=https://api.cloud.redpanda.com
    export RPK_CLOUD_AUTH_URL=https://auth.prd.cloud.redpanda.com
    export RPK_CLOUD_AUTH_AUDIENCE=cloudv2-production.redpanda.cloud
    ```

2. Next obtain a client id and secret by going to Organizations in the Cloud UI by navigating to https://cloud.redpanda.com/clients. Select or create a client you would like to use to create the network and cluster. You can copy the ID and secret to your clipboard by clicking the “Copy ID” and “Copy secret” buttons.
    ```
    export CLOUD_CLIENT_ID=<client-ID>
    export CLOUD_CLIENT_SECRET=<client-secret>
    ```

3. Set the Azure subscriptions you would like to use:

    ```
    # Where the redpanda cluster will be provisioned
    AZURE_SUBSCRIPTION_ID=<redpanda-subscription-id>

    # Where you will connect to the private link service fronting redpanda
    AZURE_PRIVATE_LINK_SUBSCRIPTION_ID=<connection-source-to-redpanda>
    ```

### Provisioning

1. Obtain an auth token
    ```
    export AUTH_TOKEN=`curl -s --request POST \
        --url "${RPK_CLOUD_AUTH_URL}/oauth/token" \
        --header 'content-type: application/x-www-form-urlencoded' \
        --data grant_type=client_credentials \
        --data client_id=$CLOUD_CLIENT_ID \
        --data client_secret=$CLOUD_CLIENT_SECRET \
        --data audience=$RPK_CLOUD_AUTH_AUDIENCE | jq -r '.access_token'`

    # MAKE SURE THIS IS POUPULATED
    echo $AUTH_TOKEN


    declare -a HEADERS=(
        "-H" "Content-Type: application/json"
        "-H" "Authorization: Bearer $AUTH_TOKEN"
    )

    ```

1. Find the Resource Group where we will create the redpanda cluster

    ```
    RESOURCE_GROUP_ID=`curl -s -X GET "${HEADERS[@]}" \
    $API_ENDPOINT/v1beta2/resource-groups | jq -r ".resource_groups[0].id"`

    # NOTE: this should have output
    echo $RESOURCE_GROUP_ID

    ```

1. Create the network that will be used by the redpanda cluster
    ```
    NETWORK_POST_BODY=`cat << EOF
    {
    "cidr_block": "10.0.0.0/20",
    "cloud_provider": "CLOUD_PROVIDER_AZURE",
    "cluster_type": "TYPE_BYOC",
    "name": "azure-byoc-network",
    "resource_group_id": "$RESOURCE_GROUP_ID",
    "region": "uksouth"
    }
    EOF`

    NETWORK_ID=`curl -s -X POST "${HEADERS[@]}" \
    -d "$NETWORK_POST_BODY" $API_ENDPOINT/v1beta2/networks |
    jq -r '.operation.metadata.network_id'`

    # NOTE: this should have output
    echo $NETWORK_ID
    ```
   * NOTE: `region` may different in your case
   * NOTE: `cidr_block` may be different in your case
1. Create the redpanda cluster with the allowed subscriptions we set before. NOTE: you can add as many other subscriptions as you would like under `allowed_subscriptions`

    ```
    CLUSTER_POST_BODY=`cat << EOF
    {
    "cloud_provider": "CLOUD_PROVIDER_AZURE",
    "connection_type": "CONNECTION_TYPE_PRIVATE",
    "name": "azure-byoc-pl",
    "resource_group_id": "$RESOURCE_GROUP_ID",
    "network_id": "$NETWORK_ID",
    "region": "uksouth",
    "throughput_tier": "tier-1-azure-v2-x86",
    "type": "TYPE_BYOC",
    "zones": ["uksouth-az1",  "uksouth-az2", "uksouth-az3"],
    "redpanda_version": "24.2",
    "azure_private_link": { 
        "allowed_subscriptions": ["$AZURE_PRIVATE_LINK_SUBSCRIPTION_ID"],
        "enabled": true,
        "connect_console": true
    }
    }
    EOF`

    RP_ID=`curl -s -X POST "${HEADERS[@]}" \
    -d "$CLUSTER_POST_BODY" $API_ENDPOINT/v1beta2/clusters | jq -r '.operation.metadata.cluster_id'`

    # NOTE: this should have output
    echo $RP_ID
    ```
   * NOTE: `region` and `zones` may be different in your case
1. Run the rpk apply to create the infrastructure for the cluster. This will take about 45 minutes to complete. 
    ```
    rpk login --save --client-id=$CLOUD_CLIENT_ID --client-secret=$CLOUD_CLIENT_SECRET

    rpk cloud byoc azure apply --redpanda-id=$RP_ID --subscription-id=$AZURE_SUBSCRIPTION_ID
    
    ```

## Connecting to Redpanda Private Link

Once the cluster has been created we can now run terraform to connect to the created cluster with private link. This terraform will provision a vm along with a private link endpoint that connects to the redpanda cluster. 



1. First fetch credentials to the Redpanda cluster:

    ```
    az login 
    az account set --subscription $AZURE_SUBSCRIPTION_ID
    az aks get-credentials -g rg-rpcloud-$RP_ID -n aks-rpcloud-$RP_ID
    secret=$(kubectl get secret redpanda-superusers -n redpanda -o jsonpath='{.data.users\.txt}' | base64 --decode)

    IFS=':' read -r user password sasl <<< "$secret"

    export USER=$user
    export PASS=$password

    ```
1. Fetch outputs from the redpanda cluster that we will use as inputs to our terraform
    ```
    DNS_RECORD=`curl -s -X GET "${HEADERS[@]}" \
    $API_ENDPOINT/v1beta2/clusters/$RP_ID | jq -r ".cluster.azure_private_link.status.dns_a_record"`

    PRIVATE_SERVICE_ID=`curl -s -X GET "${HEADERS[@]}" \
    $API_ENDPOINT/v1beta2/clusters/$RP_ID | jq -r ".cluster.azure_private_link.status.service_id"`

    CONSOLE_URL=`curl -s -X GET "${HEADERS[@]}" \
    $API_ENDPOINT/v1beta2/clusters/$RP_ID | jq -r ".cluster.redpanda_console.url"`

    echo $DNS_RECORD
    echo $PRIVATE_SERVICE_ID
    echo $CONSOLE_URL

    ```
1. Next make sure you are logged into the subscription that was allowed in the creation request: 
    ```
    az login
    az account set --subscription $AZURE_PRIVATE_LINK_SUBSCRIPTION_ID
    ```
1. Write our terraform variables out to a file so we can pick it up and use it
    ```
    export MYGROUP=your-rg-group
    cat << EOF > terraform.tfvars
    region = "uksouth"
    resource_group_name = "$MYGROUP"
    rp_endpoint_service_id = "$PRIVATE_SERVICE_ID"
    rp_id = "$RP_ID"
    rp_domain = "$DNS_RECORD"
    rp_node_count = 3
    EOF
    ```
1. Initialize the terraform and create the needed resources
    ```
    cd terraform
    terraform init 
    terraform apply -var-file="terraform.tfvars"

    ```

1. When the terraform completes copy and paste the following block. This will give us another block we can copy once we have ssh'd into the vm.
    ```
    VM_IP=$(terraform output -raw instance_public_ip)
    KEY_PATH=$(terraform output -raw private_key_file_path)

    cat << EOF 
    Copy and paste this block after sshing in:

    export USER=$USER
    export PASS=$PASS
    export CONSOLE_URL=$CONSOLE_URL
    export BROKERS=brokers.${DNS_RECORD}:30292

    EOF

    ```

1. Next ssh in and copy the output of the previous command into the vm to setup the environment variables needed to connect
    ```
    ssh -i $KEY_PATH redpanda@$VM_IP
    
    $ <paste in output from previous command>
    ```

1. Finally you now can connect to the redpanda cluster over the private link endpoint
    ```
    auth="-X user=$USER -X pass=$PASS -X sasl.mechanism=SCRAM-SHA-512 -X brokers=$BROKERS  --tls-enabled"

    rpk cluster info $auth
    rpk topic create mytopic $auth

    cat <<EOF | rpk topic $auth produce mytopic  -f '%k,%v\n'
    key1,value1
    key2,value2
    key3,value4
    EOF

    rpk topic consume mytopic $auth

    ```
1. Once  you have completed testing and want to tear down the infrastructure you can run
    ```
    terraform destroy -var-file="terraform.tfvars"

    ```
