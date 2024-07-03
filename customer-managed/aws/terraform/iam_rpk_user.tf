# The employee (or automated tooling) that will be responsible for running `rpk cloud byoc aws apply|destroy` is
# referred to as the "RPK User". The policies defined in this file are provided for documentation purposes only.
# You may grant your "RPK User" these actions in any way you wish in accordance with the norms of your organization.
#
# The RPK User must have a minimum set of permissions for creating|destroying the Redpanda Agent VM. Once the VM is
# created it will handle the remaining provisioning using the permissions granted in iam_redpanda_agent.tf.
#
# In addition to provisioning the Redpanda Agent VM some validation is performed by `rpk cloud byoc aws apply`. The
# goal of the validation logic is to verify that the customer provided resources have been configured correctly (e.g.
# is the redpanda agent granted the necessary actions? On the appropriate resources? Is the CIDR range sufficient?)
# So that these validations may be performed certain read actions are also suggested for the RPK User.

data "aws_iam_policy_document" "byovpc_rpk_user_1" {
  statement {
    effect = "Allow"
    actions = [
      # The following autoscaling actions do not support resource types
      # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonec2autoscaling.html
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeScalingActivities",

      # The following ec2 actions do not support resource types
      # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonec2.html
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribePrefixLists",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcEndpointServices",
      "ec2:DescribeVpcEndpoints",

      # The following actions are used to validate that the current user has the requisite permissions to run byoc apply
      # I do not know in advance what role the current user will be using, therefore this is wildcarded, but if the
      # rpk user has permission to list attached policies on their current role, get those policies, and retrieve the
      # default version of those policies, that is sufficient
      "iam:ListAttachedRolePolicies",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.redpanda_agent.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateLaunchTemplate",
    ]
    resources = [
      # the ID of the launch template is not known until after the cluster has been created and does not support user
      # specification of the id or an id prefix
      "arn:*:ec2:${var.region}:${local.aws_account_id}:launch-template/*"
    ]
    dynamic "condition" {
      for_each = var.condition_tags
      content {
        test     = "StringEquals"
        variable = "aws:RequestTag/${condition.key}"
        values = [
          condition.value,
        ]
      }
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeVpcAttribute",
    ]
    resources = [
      aws_vpc.redpanda.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeSubnets",
    ]
    resources = concat(tolist(aws_subnet.public.*.arn), tolist(aws_subnet.private.*.arn))
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
    ]
    resources = [
      aws_iam_policy.connectors_secrets_manager.arn,
      aws_iam_policy.console_secrets_manager.arn,
      aws_iam_policy.redpanda_cloud_storage_manager.arn,
      aws_iam_policy.cluster_autoscaler_policy.arn,
      aws_iam_policy.redpanda_agent["1"].arn,
      aws_iam_policy.redpanda_agent["2"].arn,
      aws_iam_policy.aws_ebs_csi_driver_policy.arn,
      aws_iam_policy.load_balancer_controller_policy["1"].arn,
      aws_iam_policy.load_balancer_controller_policy["2"].arn,
      aws_iam_policy.external_dns_policy.arn,
      aws_iam_policy.cert_manager.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GetInstanceProfile",
    ]
    resources = [
      aws_iam_instance_profile.redpanda_agent.arn,
      aws_iam_instance_profile.redpanda_node_group.arn,
      aws_iam_instance_profile.utility.arn,
      aws_iam_instance_profile.connectors_node_group.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
    ]
    resources = [
      aws_iam_role.redpanda_node_group.arn,
      aws_iam_role.redpanda_agent.arn,
      aws_iam_role.redpanda_cloud_storage_manager.arn,
      aws_iam_role.connectors_secrets_manager.arn,
      aws_iam_role.console_secrets_manager_redpanda.arn,
      aws_iam_role.k8s_cluster.arn,
      aws_iam_role.redpanda_utility_node_group.arn,
      aws_iam_role.connectors_node_group.arn,
      "arn:aws:iam::${local.aws_account_id}:role/${var.common_prefix}rpk-user-role-*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:SetInstanceProtection",
      "autoscaling:DeleteAutoScalingGroup",
      "autoscaling:StartInstanceRefresh",
      "autoscaling:CancelInstanceRefresh",
      "autoscaling:CreateAutoScalingGroup",
    ]
    resources = [
      "arn:aws:autoscaling:*:${local.aws_account_id}:autoScalingGroup:*:autoScalingGroupName/redpanda*",
    ]
    dynamic "condition" {
      for_each = var.condition_tags
      content {
        test     = "StringEquals"
        variable = "autoscaling:ResourceTag/${condition.key}"
        values = [
          condition.value,
        ]
      }
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateLaunchTemplateVersion",
      "ec2:DeleteLaunchTemplate",
      "ec2:DeleteTags",
    ]
    resources = [
      # the ID of the launch template is not known until after the cluster has been created and does not support user
      # specification of the id or an id prefix
      "arn:aws:ec2:*:${local.aws_account_id}:launch-template/*"
    ]
    dynamic "condition" {
      for_each = var.condition_tags
      content {
        test     = "StringEquals"
        variable = "aws:ResourceTag/${condition.key}"
        values = [
          condition.value,
        ]
      }
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateTags",
    ]
    resources = [
      # the ID of the launch template is not known until after the cluster has been created and does not support user
      # specification of the id or an id prefix
      "arn:aws:ec2:${var.region}:${local.aws_account_id}:launch-template/*",

      # the ID of the instance is not known until after the cluster has been created (and even after that is subject to
      # change) and does not support user specification of the id or an id prefix
      "arn:aws:ec2:${var.region}:${local.aws_account_id}:instance/*",

      # The ID of the volume is not known until after the cluster has been created and does not support user
      # specification of the id or an id prefix
      "arn:aws:ec2:${var.region}:${local.aws_account_id}:volume/*",

      "arn:aws:ec2:${var.region}::image/*",

      "arn:aws:ec2:${var.region}:${local.aws_account_id}:placement-group/redpanda-*-pg",

      # the ID of the VPC endpoint service is not known until after the cluster has been created and does not support
      # user specification of the id or an id prefix
      "arn:aws:ec2:${var.region}:${local.aws_account_id}:vpc-endpoint-service/*",

      # The ID of the network interface is not known until after the cluster has been created and does not support
      # user specification of the id or an id prefix
      "arn:aws:ec2:${var.region}:${local.aws_account_id}:network-interface/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values = [
        "CreateLaunchTemplate",
        "RunInstances",
        "CreateVpcEndpointServiceConfiguration",
        "CreatePlacementGroup"
      ]
    }
  }
}

data "aws_iam_policy_document" "byovpc_rpk_user_2" {
  statement {
    effect = "Allow"
    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjects",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:GetObjectVersion",
      "s3:ListBucketVersions",
    ]
    resources = [
      aws_s3_bucket.management.arn,
      "${aws_s3_bucket.management.arn}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.redpanda_cloud_storage.arn,
      "${aws_s3_bucket.redpanda_cloud_storage.arn}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [
      aws_dynamodb_table.terraform_locks.arn,
      "${aws_dynamodb_table.terraform_locks.arn}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:RunInstances",
    ]
    resources = [
      "arn:aws:ec2:*::image/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:RunInstances",
    ]
    resources = [
      # the ID of the launch template is not known until after the cluster has been created and does not support user
      # specification of the id or an id prefix
      "arn:aws:ec2:*:${local.aws_account_id}:launch-template/*",
    ]
    dynamic "condition" {
      for_each = var.condition_tags
      content {
        test     = "StringEquals"
        variable = "aws:ResourceTag/${condition.key}"
        values = [
          condition.value,
        ]
      }
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:RunInstances",
    ]
    resources = concat([aws_security_group.redpanda_agent.arn], tolist(aws_subnet.public.*.arn), tolist(aws_subnet.private.*.arn))
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:RunInstances",
    ]
    resources = [
      "arn:aws:ec2:*:${local.aws_account_id}:instance/*",
      "arn:aws:ec2:*:${local.aws_account_id}:network-interface/*",
      "arn:aws:ec2:*:${local.aws_account_id}:volume/*",
    ]
    dynamic "condition" {
      for_each = var.condition_tags
      content {
        test     = "StringEquals"
        variable = "aws:RequestTag/${condition.key}"
        values = [
          condition.value,
        ]
      }
    }
  }
}

resource "aws_iam_policy" "byovpc_rpk_user" {
  for_each = {
    "1" = data.aws_iam_policy_document.byovpc_rpk_user_1,
    "2" = data.aws_iam_policy_document.byovpc_rpk_user_2,
  }
  name_prefix = "${var.common_prefix}rpk-user-${each.key}_"
  path        = "/"
  description = "Minimum permissions required for RPK user for BYO VPC"
  policy      = each.value.json
}
