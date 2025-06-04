# Access Redpanda Services with Amazon VPC Transit Gateway

## Overview
This repository provides sample Terraform code to set up and manage an AWS transit gateway for accessing Redpanda services across multiple VPCs. The transit gateway acts as a central hub for routing traffic between VPCs, enabling communication between a Redpanda cluster and client applications hosted in different VPCs that can be in different AWS accounts. This setup is useful for organizations that need to connect VPCs to Redpanda services while maintaining centralized control over network traffic.

The Terraform code automates the following tasks:

- Create an AWS transit gateway (if not already provided).
- Attach a VPC to the transit gateway.
- Configure route tables to enable traffic routing the VPC and Redpanda cluster network.
- Share the transit gateway with other AWS accounts using AWS Resource Access Manager (RAM).
- Set up security groups to allow traffic between Redpanda services and client applications.

## Limitations
The Redpanda cluster must be either a BYOC or a BYOVPC cluster. Dedicated and Serverless clusters are not supported.

## Prerequisites

You must have the following:

- The ID of the Redpanda cluster that client applications connect to. Create a Redpanda cluster on AWS at https://cloud.redpanda.com, and get the cluster ID.
- Access to the AWS account where the Redpanda cluster is hosted. You can gather the required permissions from the Terraform code.
- Access to the AWS account where client applications are hosted if the account is different from the account hosting the Redpanda cluster. You can gather the required permissions from the Terraform code.
- [Terraform](https://developer.hashicorp.com/terraform/install) version 1.8.5 or later.

## Setup
You may want to configure [remote state](https://developer.hashicorp.com/terraform/language/state/remote) for this Terraform. For simplicity, these instructions assume local state.

## Helper script: `scripts/generate_tf_var_input.sh`
The `generate_tf_var_input.sh` script is a utility that simplifies the process of generating the required Terraform variable inputs necessary to set up the AWS transit gateway and connect it to a Redpanda cluster.

### Purpose
The script automates the generation of a JSON output containing the necessary input variables for Terraform. This includes details about the Redpanda cluster, such as its ID, seed URLs, schema registry URL, and AWS region.

### Usage

To use the script, run:
```bash
export REDPANDA_ID=<rp_id>
./scripts/generate_tf_var_input.sh ${REDPANDA_ID} > aws.auto.tfvars.json
```

Replace `<rp_id>` with the Redpanda cluster ID. You can get the cluster ID after you create the cluster in [Redpanda Cloud](https://cloud.redpanda.com).

For example:

```bash
export REDPANDA_ID=d0dmca0c4e8sqqgqbr20
./scripts/generate_tf_var_input.sh ${REDPANDA_ID} > aws.auto.tfvars.json
```

Sample output:

The script outputs a JSON object and saves the contents in the `aws.auto.tfvars.json` file:
```json
{
  "rp_id": "d0dmca0c4e8sqqgqbr20",
  "rp_kafka_seed_url": "seed-1cb35323.d0dmca0c4e8sqqgqbr20.byoc.product.cloud.redpanda.com:9092",
  "rp_http_proxy_seed_url": "https://pandaproxy-c9b46fc1.d0dmca0c4e8sqqgqbr20.byoc.product.cloud.redpanda.com:30082",
  "rp_schema_registry_url": "https://schema-registry-56a88df9.d0dmca0c4e8sqqgqbr20.byoc.product.cloud.redpanda.com:30081",
  "rp_console_url": "https://console-1cb35323.d0dmca0c4e8sqqgqbr20.byoc.product.cloud.redpanda.com",
  "region": "us-west-2"
}
```
----

## Same account access
If the Redpanda cluster and client applications are hosted in the **same AWS account**, you can use the provided Terraform code under `terraform/same-account` to set up the AWS transit gateway and attach the VPCs within the same account. This setup simplifies the process, as there is no need to share the transit gateway with another AWS account.

### 1. Go to the directory `terraform/same-account`.

### 2. Generate Terraform input variables
  Use the helper script `scripts/generate_tf_var_input.sh` to generate the required Terraform input variables:
  ```bash
  export REDPANDA_ID=<rp_id>
  ./scripts/generate_tf_var_input.sh ${REDPANDA_ID} > aws.auto.tfvars.json
  ```
  Replace `<rp_id>` with the Redpanda cluster ID.

### 3. Create Terraform variable input file
   - Create a Terraform variable input file named `aws.auto.tfvars.json` using the output from the previous step. For example:
      ```json
      {
        "rp_id": "d0dmca0c4e8sqqgqbr20",
        "rp_kafka_seed_url": "seed-1cb35323.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com:9092",
        "rp_http_proxy_seed_url": "https://pandaproxy-c9b46fc1.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com:30082",
        "rp_schema_registry_url": "https://schema-registry-56a88df9.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com:30081",
        "rp_console_url": "https://console-1cb35323.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com",
        "client_subnet_id": "subnet-0c8544528225a9f2b",
        "transit_gateway_id": "tgw-05c562f4a707ac6e5",
        "region": "us-west-2"
      }
      ```

  - Replace `client_subnet_id` with the ID of a subnet in the VPC where client applications are deployed. If `client_subnet_id` is not provided or is empty, a VPC and subnet are created. You can modify the Terraform code to adjust the CIDRs according to your needs.
  - Replace `transit_gateway_id` with the ID of an existing AWS transit gateway that you want to use to access Redpanda services. If it is not provided or is empty, an AWS transit gateway is created.

### 4. Run Terraform
   - Initialize Terraform:
     ```bash
     terraform init
     ```
   - Plan the changes:
     ```bash
     terraform plan
     ```
   - Apply the changes:
     ```bash
     terraform apply
     ```

### 5. Verify connectivity
After applying the Terraform code, the output includes instructions for testing connectivity. 

Sample output:
```plaintext
instance_id = "i-0a1b2c3d4e5f6g7h8"
instance_public_ip = "35.155.90.103"
ssh_private_key = <sensitive>
ssh_to_ec2_commands = {
  "get_ssh_key_command" = <<-EOT
      cat terraform.tfstate | jq .outputs.ssh_private_key.value | sed 's/"//g' | awk '{gsub(/\\n/,"\n")}1' > /tmp/35.155.90.103.pem; chmod 600 /tmp/35.155.90.103.pem
  EOT
  "ssh_command" = "ssh -i /tmp/35.155.90.103.pem ec2-user@35.155.90.103"
  "test_redpanda_transit_gateway_command" = "/usr/local/bin/test-transit-gateway.sh <rp-user-id> <rp-user-password>"
}
```
5a. **Create Redpanda user**

Create a user in the Redpanda Cloud UI, and assign it an ACL that allows all operations. Save the username and password to use later for verifying connectivity.

5b. **Configure SSH key**
    
Use the provided `get_ssh_key_command` to connect to the EC2 instance. For example:

  ```bash
  cat terraform.tfstate | jq .outputs.ssh_private_key.value | sed 's/"//g' | awk '{gsub(/\\n/,"\n")}1' > /tmp/35.155.90.103.pem; chmod 600 /tmp/35.155.90.103.pem
  ```

5c. **SSH to the EC2 instance**
    
Use the provided `ssh_command` to connect to the EC2 instance. For example:

  ```bash
  ssh -i /tmp/35.155.90.103.pem ec2-user@35.155.90.103
  ```

5d. **Run the test script to verify connectivity to the Redpanda cluster**

  ```bash
  /usr/local/bin/test-transit-gateway.sh <rp-user-id> <rp-user-password>
  ```
     
  The test script should confirm successful connectivity to the Redpanda cluster's Kafka, HTTP Proxy, and Schema Registry endpoints.
     
  If any issues arise, verify the route tables, security groups, and transit gateway attachment configurations.

5e. **Remove test instance**

If you don't need the test EC2 instance, you can set `deploy_client_instance` to `false` in the Terraform variable input file `aws.auto.tfvars.json` and run `terraform apply -auto-approve`.

## Cross account access
If the Redpanda cluster and client applications are hosted in **different AWS accounts**, you can use the provided Terraform code to set up an AWS transit gateway and share it with the client account using AWS Resource Access Manager (RAM).

---

You need to access the following AWS accounts using separate credentials or through different team members:

- The account where the Redpanda cluster is deployed
- The account where client applications are deployed.

---

### 1. Owner account (Redpanda cluster account): generate Terraform inputs

The AWS account hosting the Redpanda cluster is responsible for creating and sharing the transit gateway.

  Use the helper script `scripts/generate_tf_var_input.sh` to generate the required Terraform inputs:
  ```bash
  export REDPANDA_ID=<rp_id>
  ./scripts/generate_tf_var_input.sh ${REDPANDA_ID} > aws.auto.tfvars.json
  ```

   Replace `<rp_id>` with the Redpanda cluster ID.

The output from the script is used to set the variables to the Terraform inputs in the rest of the steps. For example:
   ```json
   {
     "rp_id": "d0dmca0c4e8sqqgqbr20",
     "rp_kafka_seed_url": "seed-1cb35323.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com:9092",
     "rp_http_proxy_seed_url": "https://pandaproxy-c9b46fc1.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com:30082",
     "rp_schema_registry_url": "https://schema-registry-56a88df9.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com:30081",
     "rp_console_url": "https://console-1cb35323.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com",
     "region": "us-west-2",
     "recipient_account_id": "123456789012" // Replace with the client AWS account ID
   }
   ```

---

### 2. Recipient account (client applications account): client network

- **Go to the directory** `terraform/cross-account/1_client_account_client_network`.
- **Create a Terraform variable input file named** `aws.auto.tfvars.json`. 

  Sample input:
  ```json
  {
    "client_subnet_id": "subnet-034ce442fbb34520b",
    "region": "us-west-2"
  }
  ```

  If `client_subnet_id` is not provided or is empty, a VPC and a subnet are created.

- **Run Terraform**
   - Initialize Terraform:
     ```bash
     terraform init
     ```
   - Plan the changes:
     ```bash
     terraform plan
     ```
   - Apply the changes:
     ```bash
     terraform apply
     ```

### 3. Owner account (Redpanda cluster account): transit gateway configuration

- **Go to the directory** `terraform/cross-account/2_owner_account_tgw_configuration`.
- **Create a Terraform variable input file named** `aws.auto.tfvars.json`. 
  
  Sample input:
  ```json
  {
    "rp_id": "d0dmca0c4e8sqqgqbr20",
    "client_vpc_cidr": "10.20.0.0/16",
    "transit_gateway_id": "tgw-05c562f4a707ac6e5",
    "transit_gateway_accepted_accounts": ["111111111111"],
    "region": "us-west-2"
  }
  ```

- Replace `rp_id` and `region` according to the inputs of Step 1.
- Replace `client_vpc_cidr` with the CIDR of the client VPC. You can get the value from the output of [Step 2](#2-recipient-account-client-applications-account-client-network).
- Replace `transit_gateway_id` with the ID of the transit gateway created in Step 1. If `transit_gateway_id` is not provided or is empty, a new transit gateway is created.
- Replace `transit_gateway_accepted_accounts` with the AWS account ID of the client account.

- **Run Terraform**
   - Initialize Terraform:
     ```bash
     terraform init
     ```
   - Plan the changes:
     ```bash
     terraform plan
     ```
   - Apply the changes:
     ```bash
     terraform apply
     ```

- **Gather Terraform output**

  The Terraform execution outputs the IDs of the transit gateway and route table. They are used in the next steps. 
  
  Sample output:

  ```
  transit_gateway_id = "tgw-05c562f4a707ac6e5"
  transit_gateway_route_table_rp_id = "tgw-rtb-0f8ada2d96a0e4f40"
  ```

  This step configures the transit gateway in the owner account and shares it with the recipient account using AWS Resource Access Manager (RAM).

### 4.**Recipient account (client applications account): VPC transit gateway attachment**

This step involves the recipient account (client applications account) attaching its VPC to the shared transit gateway provided by the owner account (Redpanda cluster account).

- **Go to the directory** `terraform/cross-account/3_client_account_vpc_tgw_attachment`.

- **Create a Terraform variable input file named** `aws.auto.tfvars.json`. 
  
  Sample input:
  ```json
  {
    "subnet_ids": ["subnet-034ce442fbb34520b"],
    "vpc_id": "vpc-0a1b2c3d4e5f6g7h8",
    "transit_gateway_id": "tgw-05c562f4a707ac6e5",
    "accept_attachment": true,
    "region": "us-west-2"
  }
  ```

- Replace `subnet_ids` with the IDs of the subnets in the client VPC that need to be attached to the transit gateway.
- Replace `vpc_id` with the ID of the client VPC.
- Replace `transit_gateway_id` with the ID of the transit gateway shared by the owner account.
- Replace `region` with the AWS region where the transit gateway and VPC are located.
- Set `accept_attachment` to false if all the accounts are in the same organization and auto-acceptance is configured.

---

- **Run Terraform**
   - Initialize Terraform:
     ```bash
     terraform init
     ```
   - Plan the changes:
     ```bash
     terraform plan
     ```
   - Apply the changes:
     ```bash
     terraform apply
     ```

---

- **Gather Terraform output**
  
  The Terraform execution outputs the ID of the client's VPC transit gateway attachment. 
  
  Sample output:
  ```
  vpc_transit_gateway_attachment_id = "tgw-attach-019f6559ff190dd65"
  ```

  The owner account must accept this attachment request identified `vpc_transit_gateway_attachment_id` in the next step.

### 5. **Owner account (Redpanda cluster account): accept VPC transit gateway attachment**

This step involves the owner account (Redpanda cluster account) accepting the VPC transit gateway attachment request from the recipient account (client applications account). This ensures that the client VPC is successfully attached to the transit gateway.

- **Go to the directory** `terraform/cross-account/4_rp_account_accept_vpc_tgw_attachment`.

- **Create a Terraform variable input file named** `aws.auto.tfvars.json`. 
 
  Sample input:
  ```json
  {
    "rp_id": "d0dmca0c4e8sqqgqbr20",
    "transit_gateway_id": "tgw-05c562f4a707ac6e5",
    "transit_gateway_route_table_rp_id": "tgw-rtb-0f8ada2d96a0e4f40",
    "client_vpc_cidr": "10.20.0.0/16",
    "vpc_attachment_id": "tgw-attach-019f6559ff190dd65",
    "region": "us-west-2"
  }
  ```

- Replace `rp_id` and `region` according to the output of  the helper script `scripts/generate_tf_var_input.sh`.
- Replace `transit_gateway_id` with the ID of the transit gateway.
- Replace `transit_gateway_route_table_rp_id` with the ID of the transit gateway route table associated with the Redpanda cluster. This value is an output from [Step 3](#3-owner-account-redpanda-cluster-account-transit-gateway-configuration) when configuring the transit gateway in the owner account.
- Replace `transit_gateway_attachment_id` with the ID of the transit gateway attachment created in Step 4 by the recipient account. You can get this value from the output of Step 4.
- Replace `client_vpc_cidr` with with the CIDR block of the client VPC. You can obtain this value from the output of [Step 2](#2-recipient-account-client-applications-account-client-network), where the client VPC is created or configured.

---

- **Run Terraform**
   - Initialize Terraform:
     ```bash
     terraform init
     ```
   - Plan the changes:
     ```bash
     terraform plan
     ```
   - Apply the changes:
     ```bash
     terraform apply
     ```

---

### 6. **Recipient account (client applications account): test connectivity**

This step involves the recipient account (client applications account) testing the connectivity between the client VPC and the Redpanda cluster through the transit gateway.

It deploys an EC2 instance in the client VPC, and the connectivity tests are performed using a test script that produces and consumes messages.

- **Go to the directory** `terraform/cross-account/5_client_account_test`.

- **Create a Terraform variable input file named** `aws.auto.tfvars.json`. 
  
  Sample input:
  ```json
  {
    "rp_id": "d0dmca0c4e8sqqgqbr20",
    "rp_kafka_seed_url": "seed-1cb35323.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com:9092",
    "rp_http_proxy_seed_url": "https://pandaproxy-c9b46fc1.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com:30082",
    "rp_schema_registry_url": "https://schema-registry-56a88df9.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com:30081",
    "rp_console_url": "https://console-1cb35323.d0dmca0c4e8sqqgqbr20.byoc.ign.cloud.redpanda.com",
    "rp_vpc_cidr": "10.0.0.0/16",
    "client_subnet_id": "subnet-037c0597f74dd998a",
    "transit_gateway_id": "tgw-05c562f4a707ac6e5",
    "region": "us-west-2"
  }
  ```

  Replace `rp_kafka_seed_url`, `rp_http_proxy_seed_url`, `rp_schema_registry_url`, `rp_console_url`, `rp_vpc_cidr`, `rp_id`, and `region` with the corresponding the output of the helper script `scripts/generate_tf_var_input.sh`.

  Replace `client_subnet_id` with the ID of a subnet in the client VPC where the test instance will be deployed.

  Replace `transit_gateway_id` with the ID of the transit gateway.

- **Run Terraform**
   - Initialize Terraform:
     ```bash
     terraform init
     ```
   - Plan the changes:
     ```bash
     terraform plan
     ```
   - Apply the changes:
     ```bash
     terraform apply
     ```

- **Verify connectivity**
  
  After applying the Terraform code, the output includes instructions for testing connectivity. 
  
  Sample output:
  ```plaintext
  instance_id = "i-0a1b2c3d4e5f6g7h8"
  instance_public_ip = "35.155.90.103"
  ssh_private_key = <sensitive>
  ssh_to_ec2_commands = {
    "get_ssh_key_command" = <<-EOT
        cat terraform.tfstate | jq .outputs.ssh_private_key.value | sed 's/"//g' | awk '{gsub(/\\n/,"\n")}1' > /tmp/35.155.90.103.pem; chmod 600 /tmp/35.155.90.103.pem
    EOT
    "ssh_command" = "ssh -i /tmp/35.155.90.103.pem ec2-user@35.155.90.103"
    "test_redpanda_transit_gateway_command" = "/usr/local/bin/test-transit-gateway.sh <rp-user-id> <rp-user-password>"
  }
  ```

1. **Create Redpanda user**
   
   Create a user in the Redpanda Cloud UI, and assign it an ACL that allows all operations. Save the username and password to use later for verifying connectivity.

2. **Configure SSH key**
   
   Use the provided `get_ssh_key_command` to connect to the EC2 instance. For example:
     ```bash
     cat terraform.tfstate | jq .outputs.ssh_private_key.value | sed 's/"//g' | awk '{gsub(/\\n/,"\n")}1' > /tmp/35.155.90.103.pem; chmod 600 /tmp/35.155.90.103.pem
     ```

3. **SSH to the EC2 instance**

   Use the provided `ssh_command` to connect to the EC2 instance. For example:
     ```bash
     ssh -i /tmp/35.155.90.103.pem ec2-user@35.155.90.103
     ```

4. **Run the test script**
   
   Run the test script to verify connectivity to the Redpanda cluster:
     ```bash
     /usr/local/bin/test-transit-gateway.sh <rp-user-id> <rp-user-password>
     ```

    The test script should confirm successful connectivity to the Redpanda cluster's Kafka, HTTP Proxy, and Schema Registry endpoints.

    If any issues arise, verify the route tables, security groups, and transit gateway attachment configurations.

5. **Remove test instance**
   
   If you don't need the test EC2 instance, you can destroy it by running `terraform destroy -auto-approve`.
