This document contains customer instructions for early access to the Redpanda BYOVPC AWS feature, for proof of concept 
purposes.

# Prerequisites

1. Your Redpanda representative must have enabled the BYOVPC feature flag for your organization.
2. Familiarity with the [Redpanda Public API](https://redpanda-api-documentation.netlify.app/). (e.g. How to 
authenticate and create a cluster using the API.)
3. Access to an AWS project in which you’d like to create your cluster.
4. [Minimum permissions](https://github.com/redpanda-data/cloud-examples/modules/customer-managed/examples/aws/terraform/iam_rpk_user.tf) in that 
AWS project. (Note that the link to the minimum permissions is provided simply as documentation, we do not anticipate 
that you would create the role in that file, it is provided only as a way to communicate the actions that will be 
required of the employee running rpk byoc apply.)

# Create VPC and other sensitive resources

The [terraform code](https://github.com/redpanda-data/cloud-examples/modules/customer-managed/examples/aws/terraform) contains the 
specifications for what resources are expected to exist and how they are expected to be configured.

This terraform code will create the following resources:
* IAM Roles
* IAM Instance Profiles
* IAM Role Policy Attachments
* IAM Policies
* Elastic IP
* Internet Gateway
* Route
* VPC
* Subnets
* VPC Endpoint
* Route Tables
* Route Table Associations
* VPC Endpoint Route Table Associations
* Security Groups
* Security Group Rules
* S3 Buckets
* S3 Bucket Server-Side Encryption Configurations
* S3 Bucket Versioning
* S3 Bucket Ownership Controls
* DynamoDB Table

Some of these resources may already exist in your AWS project in which case you can remove that item from the terraform
and modify references to use a data block instead of the resource.

In particular the resources in the 
[iam_rpk_user.tf](https://github.com/redpanda-data/cloud-examples/modules/customer-managed/examples/aws/terraform/iam_rpk_user.tf) file 
are not intended to be created but are only provided to serve as documentation of the minimum viable permissions for the 
employee who will run rpk byoc apply.

This terraform module outputs a number of ARN values, these will be used as inputs for the Public API calls.

# Create Redpanda Cloud Network using Public API

After [authenticating](https://redpanda-api-documentation.netlify.app/#auth) to the Public API, issue a create network 
request using the outputs from the terraform in the previous step.

For more information on the CreateNetwork schema see the 
[Public API documentation](https://redpanda-api-documentation.netlify.app/#post-/v1beta2/networks).

```shell
curl -X POST "https://api.redpanda.com/v1beta2/networks" \
  -H "accept: application/json"\
  -H "content-type: application/json" \
  -H "authorization: Bearer $PUBLIC_API_TOKEN" \
  -d @- << EOF
{
  "name":"<name you choose for your network resource>",
  "resource_group_id": "<Resource group ID of the network>",
  "cloud_provider":"CLOUD_PROVIDER_AWS",
  "region":"<region>",
  "cluster_type":"TYPE_BYOC",
  "customer_managed_resources": {
    "aws": {
      "management_bucket": {
        "arn": "<management_bucket_arn from outputs>"
      },
      "dynamodb_table": {
        "arn": "<dynamodb_table_arn from outputs>"
      },
      "private_subnets": {
        "arns": [<private_subnet_ids from outputs>]
      },
      "vpc": {
        "arn": "<vpc_arn from outputs>"
      }
    }
  }
}
EOF
```

The create network request will return a resource_id, you will need this in the create cluster step next. Example:

```shell
{
  "operation": {
    "id":"cpas8k6r4up5li18auh0",
    "metadata": {
      "@type":"type.googleapis.com/redpanda.api.controlplane.v1beta2.CreateNetworkMetadata",
      "network_id":"cpb338gekjj5i1cpj3t0"
    },
    "state":"STATE_IN_PROGRESS",
    "started_at":"2024-05-28T19:33:54.631Z",
    "type":"TYPE_CREATE_NETWORK",
    "resource_id":"cpb338gekjj5i1cpj3t0"
  }
}
```

# Create Redpanda Cloud Cluster using Public API

Issue a create cluster request using the outputs from the terraform in the prior step.

For more information on the CreateCluster schema see the
[Public API documentation](https://redpanda-api-documentation.netlify.app/#post-/v1beta2/clusters).

```shell
curl -X POST "https://api.redpanda.com/v1beta2/clusters" \
  -H "accept: application/json"\
  -H "content-type: application/json" \
  -H "authorization: Bearer $PUBLIC_API_TOKEN" \
  -d @- << EOF
{
  "cloud_provider":"CLOUD_PROVIDER_AWS",
  "connection_type":"CONNECTION_TYPE_PRIVATE",
  "name":"<name of cluster>",
  "resource_group_id":"<Resource group ID of the network>",
  "network_id":"<resource_id of network from previous step>",
  "region":"<region>",
  "throughput_tier":"<throughput tier>",
  "type":"TYPE_BYOC",
  "zones":["use2-az1","use2-az2","use2-az3"],
  "redpanda_version": "<redpanda version>",
  "customer_managed_resources": {
    "aws": {
      "agent_instance_profile": {
        "arn": "<agent_instance_profile_arn from outputs>"
      },
      "connectors_node_group_instance_profile": {
        "arn": "<connectors_node_group_instance_profile_arn from outputs>"
      },
      "redpanda_node_group_instance_profile": {
        "arn": "<redpanda_node_group_instance_profile_arn from outputs>"
      },
      "utility_node_group_instance_profile": {
        "arn": "<utility_node_group_instance_profile_arn from outputs>"
      },
      "connectors_security_group": {
        "arn": "<connectors_security_group_arn from outputs>"
      },
      "node_security_group": {
        "arn": "<node_security_group_arn from outputs>"
      },
      "utility_security_group": {
        "arn": "<utility_security_group_arn from outputs>"
      },
      "redpanda_agent_security_group": {
        "arn": "<redpanda_agent_security_group_arn from outputs>"
      },
      "redpanda_node_group_security_group": {
        "arn": "<redpanda_node_group_security_group_arn from outputs>"
      },
      "cluster_security_group": {
        "arn": "<cluster_security_group_arn from outputs>"
      },
      "k8s_cluster_role": {
        "arn": "<k8s_cluster_role_arn from outputs>"
      },
      "cloud_storage_bucket": {
        "arn": "<cloud_storage_bucket_arn from outputs>"
      }
      "permissions_boundary_policy": {
        "arn": "<permissions_boundary_policy_arn from outputs>"
      }
    }
  },
  # <This aws_private_link section is optional, see https://docs.redpanda.com/current/deploy/deployment-option/cloud/aws-privatelink/ for more information>
  "aws_private_link": {
    "enabled": true,
    "allowed_principals": [<allowed principals>],
    "connect_console": <true|false>
  },
  # <This cloud_provider_tags section is optional. If you want to provide a unique identifier to your cluster that can also be used in IAM conditionals you would need to provide that value here. At this time tags may not be deleted or modified after cluster creation.>
  "cloud_provider_tags": { "<key>": "<value>" }
}
EOF
```

The create cluster request will return a resource_id, you will need this in the next step. Example:

```shell
{
  "operation": {
    "id":"cpas8k6r4up5li18auhg",
    "metadata": {
      "@type":"type.googleapis.com/redpanda.api.controlplane.v1beta2.CreateClusterMetadata",
      "cluster_id":"cpb33c8ekjj5i1cpj3v0"
    },
    "state":"STATE_IN_PROGRESS",
    "started_at":"2024-05-28T19:34:09.501Z",
    "type":"TYPE_CREATE_CLUSTER",
    "resource_id":"cpb33c8ekjj5i1cpj3v0"
  }
}
```

# Run RPK Cloud BYOC AWS Apply

Next you will run `rpk cloud byoc aws apply` to create the initial resources required for creating a redpanda cluster in 
your cloud. Primarily this consists of an autoscaling group and an agent VM. Once the agent VM is created it will handle 
the remaining provisioning steps.

For this step you must have the at least those permissions mentioned in the prerequisites.

The following resources will be created during this step:
* S3 Objects
* Launch Template
* Autoscaling Group

```shell
rpk cloud login \
  --save \
  --client-id='<client-id>’ \
  --client-secret='<client-secret>' \
  --no-profile

rpk cloud byoc aws apply \
  --redpanda-id='<resource_id of cluster from previous step>'
```

RPK will output its progress. Example:

```shell
2024-05-28T20:38:34.020Z	INFO	.rpk.managed-byoc	aws/apply.go:112	Reconciling agent infrastructure...
2024-05-28T20:38:34.200Z	INFO	.rpk.managed-byoc	cli/cli.go:194	Running apply	{"provisioner": "redpanda-bootstrap"}
2024-05-28T20:39:09.104Z	INFO	.rpk.managed-byoc	cli/cli.go:204	Finished apply	{"provisioner": "redpanda-bootstrap"}
2024-05-28T20:39:09.104Z	INFO	.rpk.managed-byoc	cli/cli.go:194	Running apply	{"provisioner": "redpanda-network"}
2024-05-28T20:41:41.962Z	INFO	.rpk.managed-byoc	cli/cli.go:204	Finished apply	{"provisioner": "redpanda-network"}
2024-05-28T20:41:41.962Z	INFO	.rpk.managed-byoc	cli/cli.go:194	Running apply	{"provisioner": "redpanda-agent"}
2024-05-28T20:42:40.767Z	INFO	.rpk.managed-byoc	cli/cli.go:204	Finished apply	{"provisioner": "redpanda-agent"}
2024-05-28T20:42:40.768Z	INFO	.rpk.managed-byoc	aws/apply.go:158	The Redpanda cluster is deploying. This can take up to 45 minutes. View status at https://cloud.redpanda.com/clusters/cpb4074p81130pqt8gjg/overview.
```

# Wait for cluster creation to complete

At this point the agent VM is running and will handle the remaining setup steps. This can take up to 45 minutes. When it 
is complete the cluster status should be updated to ‘Running’. If the cluster status is still ‘Creating’ after that 
time, reach out to Redpanda support to investigate.

You can check the cluster status via the API or using the website.

Example using returned `operation_id`:

```shell
curl -X GET "https://api.redpanda.com/v1beta2/operations/<operation_id>" \
  -H "accept: application/json"\
  -H "content-type: application/json" \
  -H "authorization: Bearer $PUBLIC_API_TOKEN"
```

Example retrieving cluster:

```shell
curl -X GET "https://api.redpanda.com/v1beta2/clusters/<cluster_id>" \
  -H "accept: application/json"\
  -H "content-type: application/json" \
  -H "authorization: Bearer $PUBLIC_API_TOKEN"
```
