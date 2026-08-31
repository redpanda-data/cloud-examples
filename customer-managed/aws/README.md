# Overview

This [Terraform](https://developer.hashicorp.com/terraform) configuration creates the AWS resources
customers are responsible for in association with a Redpanda customer-managed VPC cluster. These
resources should be created in advance by the customer and then provided to Redpanda during cluster
creation.

It is standalone: the resources are declared here directly rather than delegated to the
[`redpanda-data/redpanda-byovpc/aws`](https://registry.terraform.io/modules/redpanda-data/redpanda-byovpc/aws/latest)
registry module. The module remains the maintained implementation, so consult
[its repository](https://github.com/redpanda-data/terraform-aws-redpanda-byovpc) when comparing
behaviour; changes made there do not flow into this copy automatically.

> There are resources here that may already exist within your environment (for example, the VPC) that you
> don't want to create. Variables are provided for this purpose.

> This code is provided as an example and should be reviewed to ensure it adheres to policies within your organization.

> **Migrating from a previous version:** if you applied a copy of this Terraform while it delegated to the registry
> module, your state holds addresses under `module.byovpc.*`. `moved.tf` rewrites each one back to its top-level
> address, so `terraform plan` against an existing state should show **no changes**. A `moved` block whose source is
> absent from state is ignored, so a first-time apply is unaffected.

# Prerequisites

1. Access to an AWS project where you want to create your cluster
2. Knowledge of your internal VPC and subnet configuration (for example, the ARN of the VPC and private subnets)
3. Permission to create, modify, and delete the resources described by this Terraform
4. [Terraform](https://developer.hashicorp.com/terraform/install) version 1.8.5 or later

# Setup

> You may want to configure [remote state](https://developer.hashicorp.com/terraform/language/state/remote) for this 
> Terraform. For simplicity, these instructions assume local state.

## Configure the variables

The [variables.tf]() file contains a number of variables that allow you to modify this code to meet your specific needs.
In some cases, they let you skip creation of certain resources (for example, the VPC) or modify the configuration of a
resource.

Create a JSON file called `byoc.auto.tfvars.json` inside the Terraform directory.

```shell
{
  "aws_account_id": "",
  "region": "",
  "common_prefix": "",
  "condition_tags": {
  },
  "default_tags": {
  },
  "ignore_tags": [
  ],
  "vpc_id": "",
  "private_subnet_ids": [],
  "private_subnet_cidrs": [],
  "public_subnet_cidrs": [],
  "public_subnet_ids": [],
  "zones": [],
  "enable_private_link": true|false,
  "enable_public_private_connections": true|false,
  "create_internet_gateway": true|false,
  "create_rpk_user": true|false,
  "force_destroy_cloud_storage": true|false
}
```

| Variable Name               | Description                                                                                                                                                                                                                                                                                                                                                                                                      | Default                                                                                   | Required                                                               |
|-----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|------------------------------------------------------------------------|
| aws_account_id              | AWS account ID in which to create the resources, if not already authenticated via the methods described [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration).                                                                                                                                                                                              | none                                                                                      | no                                                                     |
| region                      | [AWS region](https://docs.redpanda.com/redpanda-cloud/reference/tiers/byoc-tiers/#tabs-1-amazon-web-services-aws) in which to create the resources.                                                                                                                                                                                                                                                              | none                                                                                      | yes                                                                    |
| common_prefix               | String that will be used as a prefix in the name of all resources where prefix is supported.                                                                                                                                                                                                                                                                                                                     | "redpanda"                                                                                | yes                                                                    |
| condition_tags              | Key/value pairs for tags that will be included as conditions on any IAM policies where supported. For example, you can include `cluster:staging-east` as a condition tag, and permissions are restricted to only those resources that include the tag `cluster:staging-east`. Note that any tag included here must also be provided during cluster creation in the `cloud_provider_tags` field of the Cloud API. | redpanda-managed: true                                                                    | no                                                                     |
| default_tags                | Tags to apply to all resources created here.                                                                                                                                                                                                                                                                                                                                                                     | none                                                                                      | no                                                                     |
| ignore_tags                 | Tags which, if present on these resources in the cloud but not in this code, will be ignored.                                                                                                                                                                                                                                                                                                                    | none                                                                                      | no                                                                     |
| vpc_id                      | ID of the VPC, if created external to this Terraform code. When provided, this code skips creation of the VPC.                                                                                                                                                                                                                                                                                                   | none                                                                                      | no                                                                     |
| private_subnet_ids          | IDs of the private subnets associated with the provided `vpc_id`, if created external to this Terraform code. When provided, this code skips creation of the private subnets.                                                                                                                                                                                                                                    | none                                                                                      | Either `private_subnet_ids` or `private_subnet_cidrs` must be provided |
| private_subnet_cidrs        | One subnet is created per CIDR block in this list. If this list is blank, then no subnets are created and `private_subnet_ids` is required.                                                                                                                                                                                                                                                                      | "10.0.0.0/24", "10.0.2.0/24", "10.0.4.0/24", "10.0.6.0/24", "10.0.8.0/24", "10.0.10.0/24" | Either `private_subnet_ids` or `private_subnet_cidrs` must be provided |
| public_subnet_cidrs         | One subnet is created per CIDR block in this list and associated to the main route table. If no CIDRs are provided, no subnets are created. It is not common to provide these.                                                                                                                                                                                                                                   | "10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24", "10.0.7.0/24", "10.0.9.0/24", "10.0.11.0/24" | no                                                                     |
| public_subnet_ids           | IDs of existing public subnets associated with the provided `vpc_id`. Required for a cluster with both public and private connections, which places broker nodes and the internet-facing seed load balancer in public subnets. Each must route to an internet gateway and be tagged `kubernetes.io/role/elb` = 1. Mutually exclusive with `public_subnet_cidrs`.                                                    | none                                                                                      | Only for public+private connections in an externally created VPC       |
| zones                       | Subnets are created in these [AWS availability zones](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#az-ids).                                                                                                                                                                                                                                                         | none                                                                                      | Only when `private_subnet_cidrs` or `public_subnet_cidrs` is provided  |
| enable_private_link         | When true, additional permissions that are required by [AWS Private Link](https://docs.redpanda.com/redpanda-cloud/networking/aws-privatelink/) are granted.                                                                                                                                                                                                                                                     | false                                                                                     | no                                                                     |
| enable_public_private_connections | When true, allows this VPC to host a cluster serving both public and private connections. Adds an ingress rule for the public connection's Redpanda broker ports (30042-30044) from `0.0.0.0/0` on the Redpanda node security group; the private connection's ports (30092-30094) stay restricted to private ranges. Requires a public subnet in every availability zone spanned by the private subnets.       | false                                                                                     | no                                                                     |
| create_internet_gateway     | When true, an Internet Gateway and route to the Gateway is created for inbound communication from Redpanda Control Plane. This can be provisioned and managed separately.                                                                                                                                                                                                                                        | false                                                                                     | no                                                                    |
| create_rpk_user             | When true, IAM policies reflecting the permissions required by the user running RPK are created. This is not commonly needed.                                                                                                                                                                                                                                                                                    | false                                                                                     | yes                                                                    |
| force_destroy_cloud_storage | When true, the cloud storage bucket is destroyed when this Terraform is destroyed. Not recommended for production.                                                                                                                                                                                                                                                                                               | false                                                                                     | yes                                                                    |
| source_cluster_bucket_names | Set of bucket names associated with redpanda clusters for which this cluster may be a read replica. For more information see: https://docs.redpanda.com/redpanda-cloud/get-started/cluster-types/byoc/remote-read-replicas/                                                                                                                                                                                      | empty set                                                                                 | no                                                                     |
| reader_cluster_id           | ID of the redpanda cluster. Only required when source_cluster_bucket_arns is provided. For more information see: https://docs.redpanda.com/redpanda-cloud/get-started/cluster-types/byoc/remote-read-replicas/                                                                                                                                                                                                   | empty string                                                                              | no                                                                     |

## Initialize the Terraform

Initialize the working directory containing Terraform configuration files.

```shell
terraform init
```

## Apply the Terraform

```shell
terraform apply
```

## Capture the output

The output of `terraform apply` should display a number of output values. For example:

```shell
agent_instance_profile_arn = "..."
byovpc_rpk_user_policy_arns = "[...]"
cloud_storage_bucket_arn = "..."
cluster_security_group_arn = "..."
connectors_node_group_instance_profile_arn = "..."
connectors_security_group_arn = "..."
dynamodb_table_arn = "..."
k8s_cluster_role_arn = "..."
management_bucket_arn = "..."
node_security_group_arn = "..."
permissions_boundary_policy_arn = "..."
private_subnet_ids = "[...]"
public_subnet_arns = "[...]"
redpanda_agent_role_arn = "..."
redpanda_agent_security_group_arn = "..."
redpanda_node_group_instance_profile_arn = "..."
redpanda_node_group_security_group_arn = "..."
utility_node_group_instance_profile_arn = "..."
utility_security_group_arn = "..."
vpc_arn = "..."
```

These values can also be retrieved at any time by running `terraform output`.

Note these values. They are needed for the next steps. To continue with cluster creation, see 
[Create a BYOVPC Cluster on AWS](https://docs.redpanda.com/redpanda-cloud/get-started/cluster-types/byoc/aws/vpc-byo-aws/). 
