# Access Redpanda Services Via AWS Transit Gateway

## Overview
This repository provides sample Terraform code to set up and manage an AWS Transit Gateway for accessing Redpanda services across multiple VPCs. The Transit Gateway acts as a central hub for routing traffic between VPCs, enabling communication between a Redpanda cluster and client applications hosted in different VPCs
that can be in different AWS accounts.

**Constraints: Redpanda Cluster MUST be either BYOC or BYO VPC cluster.**

The Terraform code automates the following tasks:

- Creation of an AWS Transit Gateway (if not already provided).
- Attachment of a VPC to the Transit Gateway.
- Configuration of route tables to enable traffic routing the VPC and Redpanda cluster network.
- Sharing the Transit Gateway with other AWS accounts using AWS Resource Access Manager (RAM).
- Setting up security groups to allow traffic between Redpanda services and client applications.

This setup is ideal for organizations that need to connect VPCs to Redpanda services while maintaining centralized control over network traffic.

## Prerequisites

1. You need the ID of Redpanda cluster that client applications connect to. Create an AWS Redpanda Cluster at https://cloud.redpanda.com, and get the cluster ID.
2. Access to the AWS account where the Redpanda cluster is hosted. You can gather the required permissions from the Terraform code.
3. Access to the AWS account where client applications are hosted if the account is different than the account hosting the Redpanda cluster. You can gather the required permissions from the Terraform code.
4. [Terraform](https://developer.hashicorp.com/terraform/install) version 1.8.5 or later

## Setup

> You may want to configure [remote state](https://developer.hashicorp.com/terraform/language/state/remote) for this
> Terraform. For simplicity, these instructions assume local state.

## Helper Script: `scripts/generate_tf_var_input.sh`
The `generate_tf_var_input.sh` script is a utility provided to simplify the process of generating the required Terraform variable inputs regarding Redpanda Cluster for setting up the AWS Transit Gateway and connecting it to a Redpanda cluster.

### Purpose
The script automates the generation of a JSON output containing the necessary input variables for Terraform. This includes details about the Redpanda cluster, such as its ID, seed URLs, schema registry URL, and the AWS region.

### Usage
To use the script, run the following command:
```bash
./scripts/generate_tf_var_input.sh <rp_id>
```

Replace `<rp_id>` with the Redpanda cluster ID. You can obtain the cluster ID by creating a Redpanda cluster at [Redpanda Cloud](https://cloud.redpanda.com).

### Example
```bash
./scripts/generate_tf_var_input.sh d0dmca0c4e8sqqgqbr20
```

### Sample Output
The script outputs a JSON object:
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

## Same Account Access
If the Redpanda cluster and client applications are hosted in the **same AWS account**, you can use the provided Terraform code under `terraform/same-account` to set up the AWS Transit Gateway and attach the VPCs within the same account. This setup simplifies the process as there is no need to share the Transit Gateway with another AWS account.

### 1. Go to the directory `terraform/same-account`.

### 2. Generate Terraform Input Variables
   Use the helper script `scripts/generate_tf_var_input.sh` to generate the required Terraform input variables:
   ```bash
   ./scripts/generate_tf_var_input.sh <rp_id>
   ```
   Replace `<rp_id>` with the Redpanda cluster ID.

### 3. Create Terraform Variable Input File
   Create a Terraform variable input file named `aws.auto.tfvars.json` by using the output above. For example:
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

  - Replace `client_subnet_id` with the ID of a subnet in the VPC where client applications are deployed. If `client_subnet_id` is not provided or is empty, a VPC and subnet will be created. You can modify the Terraform code to adjust the CIDRs according to your needs.
  - Replace `transit_gateway_id` with the ID of an existing AWS Transit Gateway that you would like to use to access Redpanda services. If it is not provided or is empty, an AWS Transit Gateway will be created.

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

### 5. Verify Connectivity
After applying the Terraform code, the output will include instructions for testing connectivity. Sample output:
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

- **Configure SSH key**:
   - Use the provided `get_ssh_key_command` to connect to the EC2 instance, e.g.:
     ```bash
     cat terraform.tfstate | jq .outputs.ssh_private_key.value | sed 's/"//g' | awk '{gsub(/\\n/,"\n")}1' > /tmp/35.155.90.103.pem; chmod 600 /tmp/35.155.90.103.pem
     ```

- **SSH to the EC2 Instance**:
   - Use the provided `ssh_command` to connect to the EC2 instance, e.g.:
     ```bash
     ssh -i /tmp/35.155.90.103.pem ec2-user@35.155.90.103
     ```

- **Run the Test Script**:
   - Execute the test script to verify connectivity to the Redpanda cluster:
     ```bash
     /usr/local/bin/test-transit-gateway.sh <rp-user-id> <rp-user-password>
     ```

The test script should confirm successful connectivity to the Redpanda cluster's Kafka, HTTP Proxy, and Schema Registry endpoints.

If any issues arise, verify the route tables, security groups, and Transit Gateway attachment configurations.

## Cross Account Access
If the Redpanda cluster and client applications are hosted in **different AWS accounts**, you can use the provided Terraform code to set up an AWS Transit Gateway and share it with the client account using AWS Resource Access Manager (RAM).

---

You will need to access the following AWS accounts using separate credentials or through different team members.

- The account where the Redpanda cluster is deployed
- The account where client applications are deployed.

---

### 1. Owner Account (Redpanda Cluster Account): Generate Terraform Inputs

The AWS account hosting the Redpanda cluster is responsible for creating and sharing the Transit Gateway.

  Use the helper script `scripts/generate_tf_var_input.sh` to generate the required Terraform inputs:
   ```bash
   ./scripts/generate_tf_var_input.sh <rp_id>
   ```
   Replace `<rp_id>` with the Redpanda cluster ID.

The output from the script will be used to set the variables to the TF inputs at the rest the steps. For example:
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

### 2. Recipient Account (Client Applications Account): Client Network

- **Go to the directory** `terraform/cross-account/1_client_account_client_network`
- **Create a Terraform variable input file named** `aws.auto.tfvars.json`. Sample input,
  ```json
  {
    "client_subnet_id": "subnet-034ce442fbb34520b",
    "region": "us-west-2"
  }
  ```

If `client_subnet_id` is not provided or is empty, a VPC and a subnet will be created.

- **Run Terraform**:
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

### 3. Owner Account (Redpanda Cluster Account): Transit Gateway Configuration

- **Go to the directory** `terraform/cross-account/2_owner_account_tgw_configuration`.
- **Create a Terraform variable input file named** `aws.auto.tfvars.json`. Sample input:
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
- Replace `transit_gateway_id` with the ID of the Transit Gateway created in Step 1. If `transit_gateway_id` is not provided or is empty, a new Transit Gateway will be created.
- Replace `transit_gateway_accepted_accounts` with the AWS account ID of the client account.

- **Run Terraform**:
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

- **Gather Terraform Output**
The Terraform execution will output the IDs of Transit Gateway and route table. They will be used by the next steps. Sample output,

  ```
  transit_gateway_id = "tgw-05c562f4a707ac6e5"
  transit_gateway_route_table_rp_id = "tgw-rtb-0f8ada2d96a0e4f40"
  ```

This step configures the Transit Gateway in the owner account and shares it with the recipient account using AWS Resource Access Manager (RAM).

#### 4.**Recipient Account (Client Applications Account): VPC Transit Gateway Attachment**

This step involves the recipient account (Client Applications Account) attaching its VPC to the shared Transit Gateway provided by the owner account (Redpanda Cluster Account).

- **Go to the directory** `terraform/cross-account/3_client_account_vpc_tgw_attachment`.

- **Create a Terraform variable input file named** `aws.auto.tfvars.json`. Sample input:
```json
{
  "subnet_ids": ["subnet-034ce442fbb34520b"],
  "vpc_id": "vpc-0a1b2c3d4e5f6g7h8",
  "transit_gateway_id": "tgw-05c562f4a707ac6e5",
  "region": "us-west-2"
}
```

- Replace `subnet_ids` with the IDs of the subnets in the client VPC that need to be attached to the Transit Gateway.
- Replace `vpc_id` with the ID of the client VPC.
- Replace `transit_gateway_id` with the ID of the Transit Gateway shared by the owner account.
- Replace `region` with the AWS region where the Transit Gateway and VPC are located.

---

- **Run Terraform**:
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

- **Gather Terraform Output**
The Terraform execution will output the ID of client's VPC Transit Gateway Attachment. Sample output,
```
vpc_transit_gateway_attachment_id = "tgw-attach-019f6559ff190dd65"
```

The owner account will need to accept this attachment request identified `vpc_transit_gateway_attachment_id` by in the next step.

#### 5. **Owner Account (Redpanda Cluster Account): Accept VPC Transit Gateway Attachment**

This step involves the owner account (Redpanda Cluster Account) accepting the VPC Transit Gateway attachment request from the recipient account (Client Applications Account). This ensures that the client VPC is successfully attached to the Transit Gateway.

- **Go to the directory** `terraform/cross-account/4_rp_account_accept_vpc_tgw_attachment`.

- **Create a Terraform variable input file named** `aws.auto.tfvars.json`. Sample input:
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
- Replace `transit_gateway_id` with the ID of the Transit Gateway.
- Replace `transit_gateway_route_table_rp_id` with the ID of the Transit Gateway route table associated with the Redpanda cluster. This value is an output from [Step 3](#3-owner-account-redpanda-cluster-account-transit-gateway-configuration) when configuring the Transit Gateway in the owner account.
- Replace `transit_gateway_attachment_id` with the ID of the Transit Gateway attachment created in Step 4 by the recipient account. You can get this value from the output of Step 4.
- Replace `client_vpc_cidr` with with the CIDR block of the client VPC. You can obtain this value from the output of [Step 2](#2-recipient-account-client-applications-account-client-network), where the client VPC is created or configured.

---

- **Run Terraform**:
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

#### 6. **Recipient Account (Client Applications Account): Test Connectivity**

This step involves the recipient account (Client Applications Account) testing the connectivity between the client VPC and the Redpanda cluster through the Transit Gateway.
It deploys an EC2 instance in the client VPC, and the connectivity tests are performed using a test script that produces and consumes messages.

- **Go to the directory** `terraform/cross-account/5_client_account_test`.

- **Create a Terraform variable input file named** `aws.auto.tfvars.json`. Sample input:
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

  Replace `rp_kafka_seed_url`, `rp_http_proxy_seed_url`, `rp_schema_registry_url`, `rp_console_url`, `rp_vpc_cidr`, `rp_id`, `region` with the corresponding the output of the helper script `scripts/generate_tf_var_input.sh`.

  Replace `client_subnet_id` with the ID of a subnet in the client VPC where the test instance will be deployed.

  Replace `transit_gateway_id` with the ID of the Transit Gateway.

- **Run Terraform**:
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

- **Verify Connectivity**:
After applying the Terraform code, the output will include instructions for testing connectivity. Sample output:
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

1. **Configure SSH key**:
   - Use the provided `get_ssh_key_command` to connect to the EC2 instance, e.g.:
     ```bash
     cat terraform.tfstate | jq .outputs.ssh_private_key.value | sed 's/"//g' | awk '{gsub(/\\n/,"\n")}1' > /tmp/35.155.90.103.pem; chmod 600 /tmp/35.155.90.103.pem
     ```

2. **SSH to the EC2 Instance**:
   - Use the provided `ssh_command` to connect to the EC2 instance, e.g.:
     ```bash
     ssh -i /tmp/35.155.90.103.pem ec2-user@35.155.90.103
     ```

3. **Run the Test Script**:
   - Execute the test script to verify connectivity to the Redpanda cluster:
     ```bash
     /usr/local/bin/test-transit-gateway.sh <rp-user-id> <rp-user-password>
     ```

The test script should confirm successful connectivity to the Redpanda cluster's Kafka, HTTP Proxy, and Schema Registry endpoints.

If any issues arise, verify the route tables, security groups, and Transit Gateway attachment configurations.
