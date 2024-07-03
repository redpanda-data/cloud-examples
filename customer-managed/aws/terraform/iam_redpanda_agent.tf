data "aws_iam_policy_document" "redpanda_agent1" {
  statement {
    effect = "Allow"
    actions = [
      # The following autoscaling actions do not support resource types
      # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonec2autoscaling.html
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeTags",
      "autoscaling:DescribeTerminationPolicyTypes",
      "autoscaling:DescribeInstanceRefreshes",
      "autoscaling:DescribeLaunchConfigurations",

      # The following cloudwatch actions do not support resource types
      # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazoncloudwatch.html
      "cloudwatch:GetMetricData",

      # The following ec2 actions do not support resource types
      # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonec2.html
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribePlacementGroups",
      "ec2:DescribeVpcs",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSecurityGroupRules",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNatGateways",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcEndpointServices",
      "ec2:DescribeVolumes",

      # The following elasticloadbalancing actions do not support resource types
      # https://docs.aws.amazon.com/service-authorization/latest/reference/list_awselasticloadbalancingv2.html
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeTargetGroupAttributes",

      # The following iam actions do not support resource types
      # https://docs.aws.amazon.com/service-authorization/latest/reference/list_awsidentityandaccessmanagementiam.html
      "iam:ListPolicies",
      "iam:ListRoles",

      # The following route53 actions do not support resource types
      # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonroute53.html
      "route53:CreateHostedZone",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:GetChange",
    ]
    resources = [
      # the ID of the change is not known prior to creating the change and does not support user specification of the id
      # or an id prefix
      "arn:aws:route53:::change/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:GetHostedZone",
      "route53:GetDNSSEC",
      "route53:ListTagsForResource",
      "route53:ListResourceRecordSets",
      "route53:ChangeResourceRecordSets",
      "route53:ChangeTagsForResource",
      "route53:DeleteHostedZone",
    ]
    resources = [
      # the ID of the hosted zone is not known until after the cluster has been created and does not support user
      # specification of the id or an id prefix
      "arn:aws:route53:::hostedzone/*"
    ]
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
      "ec2:CreateLaunchTemplate",
    ]
    resources = [
      # the ID of the launch template is not known until after the cluster has been created and does not support user
      # specification of the id or an id prefix
      "arn:aws:ec2:${var.region}:${local.aws_account_id}:launch-template/*"
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
      "ec2:CreatePlacementGroup",
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${local.aws_account_id}:placement-group/redpanda-*-pg"
    ]
    dynamic "condition" {
      for_each = var.condition_tags
      content {
        test = "StringEquals"

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
      "ec2:CreateLaunchTemplateVersion"
    ]
    resources = [
      # the ID of the launch template is not known until after the cluster has been created and does not support user
      # specification of the id or an id prefix
      "arn:aws:ec2:${var.region}:${local.aws_account_id}:launch-template/*"
    ]
    dynamic "condition" {
      for_each = var.condition_tags
      content {
        test     = "StringEquals"
        variable = "ec2:ResourceTag/${condition.key}"
        values = [
          condition.value,
        ]
      }
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DeletePlacementGroup",
    ]
    resources = [
      "arn:aws:ec2:${var.region}:${local.aws_account_id}:placement-group/redpanda-*-pg"
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

  statement {
    effect = "Allow"
    actions = [
      "ec2:RunInstances",
    ]
    resources = concat(
      [
        # the ID of the instance is not known until after the cluster has been created (and even after that is subject to
        # change) and does not support user specification of the id or an id prefix
        "arn:aws:ec2:*:${local.aws_account_id}:instance/*",

        # The ID of the network interface is not known until after the cluster has been created and does not support
        # user specification of the id or an id prefix
        "arn:aws:ec2:*:${local.aws_account_id}:network-interface/*",

        # The ID of the volume is not known until after the cluster has been created and does not support user
        # specification of the id or an id prefix
        "arn:aws:ec2:*:${local.aws_account_id}:volume/*",

        "arn:aws:ec2:*:${local.aws_account_id}:security-group/*",

        # the ID of the launch template is not known until after the cluster has been created and does not support user
        # specification of the id or an id prefix
        "arn:aws:ec2:*:${local.aws_account_id}:launch-template/*",

        "arn:aws:ec2:*::image/*",
      ],
    aws_subnet.private.*.arn)
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteLaunchTemplate",
      "ec2:ModifyLaunchTemplate",
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
        variable = "ec2:ResourceTag/${condition.key}"
        values = [
          condition.value,
        ]
      }
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "eks:*",
    ]
    resources = [
      "arn:aws:eks:*:${local.aws_account_id}:cluster/redpanda-*",
      "arn:aws:eks:*:${local.aws_account_id}:addon/*",
    ]
  }

  statement {
    sid    = "RedpandaAgentInstanceProfile"
    effect = "Allow"
    actions = [
      "iam:GetInstanceProfile",
      "iam:TagInstanceProfile",
    ]
    resources = [
      aws_iam_instance_profile.redpanda_agent.arn,
      aws_iam_instance_profile.redpanda_node_group.arn,
      aws_iam_instance_profile.utility.arn,
      aws_iam_instance_profile.connectors_node_group.arn
    ]
  }
}

data "aws_iam_policy_document" "redpanda_agent2" {
  statement {
    effect = "Allow"
    actions = [
      "iam:GetOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:CreateOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
    ]
    resources = [
      "arn:aws:iam::${local.aws_account_id}:oidc-provider/oidc.eks.*.amazonaws.com",
      "arn:aws:iam::${local.aws_account_id}:oidc-provider/oidc.eks.*.amazonaws.com/id/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
    ]
    resources = [
      aws_iam_policy.aws_ebs_csi_driver_policy.arn,
      aws_iam_policy.cert_manager.arn,
      aws_iam_policy.external_dns_policy.arn,
      aws_iam_policy.load_balancer_controller_policy["1"].arn,
      aws_iam_policy.load_balancer_controller_policy["2"].arn,
      # redpanda_agent1 and redpanda_agent2, cannot be referenced by object due to cycle
      "arn:aws:iam::${local.aws_account_id}:policy/redpanda-agent-*-*",
      aws_iam_policy.cluster_autoscaler_policy.arn,
      aws_iam_policy.redpanda_cloud_storage_manager.arn,
      aws_iam_policy.connectors_secrets_manager.arn,
      aws_iam_policy.console_secrets_manager.arn,
      "arn:aws:iam::aws:policy/Amazon*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:PassRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
    ]
    resources = [
      aws_iam_role.redpanda_cloud_storage_manager.arn,
      aws_iam_role.redpanda_agent.arn,
      aws_iam_role.redpanda_node_group.arn,
      aws_iam_role.redpanda_utility_node_group.arn,
      aws_iam_role.connectors_node_group.arn,
      aws_iam_role.console_secrets_manager_redpanda.arn,
      aws_iam_role.k8s_cluster.arn,
      aws_iam_role.connectors_secrets_manager.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.management.arn,
      "${aws_s3_bucket.management.arn}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:List*",
      "s3:Get*",
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
      "autoscaling:*",
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
      "ec2:TerminateInstances",
      "ec2:RebootInstances",
    ]
    resources = [
      # the ID of the instance is not known until after the cluster has been created (and even after that is subject to
      # change) and does not support user specification of the id or an id prefix
      "arn:aws:ec2:${var.region}:${local.aws_account_id}:instance/*"
    ]
    dynamic "condition" {
      for_each = var.condition_tags
      content {
        test     = "StringEquals"
        variable = "ec2:ResourceTag/${condition.key}"
        values = [
          condition.value,
        ]
      }
    }
  }
}

data "aws_iam_policy_document" "redpanda_agent_private_link" {
  count = var.enable_private_link ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:CreateListener",
    ]
    resources = [
      # the ID of the load balancer is not known until after the cluster has been created
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:loadbalancer/net/*"
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
      "elasticloadbalancing:AddTags",
    ]
    resources = [
      # the ID of the load balancer is not known until after the cluster has been created
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:loadbalancer/net/*",

      # the ID of the listener is not known until after the cluster has been created
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:listener/net/*",

      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:targetgroup/*-rp-*",
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:targetgroup/*-kf-*/*",
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:targetgroup/*-seed/*",
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:targetgroup/*-console/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "elasticloadbalancing:CreateAction"
      values = [
        "CreateListener",
        "CreateTargetGroup",
      ]
    }
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
      "elasticloadbalancing:CreateTargetGroup",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:targetgroup/*-rp-*",
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:targetgroup/*-kf-*/*",
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:targetgroup/*-seed/*",
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:targetgroup/*-console/*"
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
      "elasticloadbalancing:DeleteListener",
    ]
    resources = [
      # the ID of the listener is not known until after the cluster has been created
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:listener/net/*"
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
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:RegisterTargets",
    ]
    resources = [
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:targetgroup/*-rp-*",
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:targetgroup/*-kf-*/*",
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:targetgroup/*-seed/*",
      "arn:aws:elasticloadbalancing:${var.region}:${local.aws_account_id}:targetgroup/*-console/*"
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
      "ec2:CreateVpcEndpointServiceConfiguration",
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
    resources = [
      # the ID of the VPC endpoint service is not known until after the cluster has been created and does not support
      # user specification of the id or an id prefix
      "arn:aws:ec2:${var.region}:${local.aws_account_id}:vpc-endpoint-service/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DeleteVpcEndpointServiceConfigurations",
      "ec2:ModifyVpcEndpointServiceConfiguration",
      "ec2:ModifyVpcEndpointServicePermissions",
      "ec2:AcceptVpcEndpointConnections",
      "ec2:CreateVpcEndpointConnectionNotification",
      "ec2:DeleteVpcEndpointConnectionNotifications",
      "ec2:ModifyVpcEndpointConnectionNotification",
      "ec2:ModifyVpcEndpointServicePayerResponsibility",
      "ec2:RejectVpcEndpointConnections",
      "ec2:StartVpcEndpointServicePrivateDnsVerification",
      "ec2:DescribeVpcEndpointServicePermissions",
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
    resources = [
      # the ID of the VPC endpoint service is not known until after the cluster has been created and does not support
      # user specification of the id or an id prefix
      "arn:aws:ec2:${var.region}:${local.aws_account_id}:vpc-endpoint-service/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      # The following ec2 actions do not support resource types
      # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonec2.html
      "ec2:DescribeVpcEndpointServiceConfigurations",
      "ec2:DescribeVpcEndpointConnectionNotifications",
      "ec2:DescribeVpcEndpointConnections",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "redpanda_agent_trust_ec2" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "redpanda_agent" {
  name_prefix        = "${var.common_prefix}agent-"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.redpanda_agent_trust_ec2.json
}

resource "aws_iam_instance_profile" "redpanda_agent" {
  name_prefix = "${var.common_prefix}agent-"
  role        = aws_iam_role.redpanda_agent.name
}

resource "aws_iam_policy" "redpanda_agent" {
  for_each = {
    "1" = data.aws_iam_policy_document.redpanda_agent1
    "2" = data.aws_iam_policy_document.redpanda_agent2
  }
  name_prefix = "${var.common_prefix}agent-${each.key}-"
  policy      = each.value.json
}

resource "aws_iam_role_policy_attachment" "redpanda_agent" {
  for_each = {
    "1" = aws_iam_policy.redpanda_agent["1"].arn,
    "2" = aws_iam_policy.redpanda_agent["2"].arn,
  }
  role       = aws_iam_role.redpanda_agent.name
  policy_arn = each.value
}

resource "aws_iam_policy" "redpanda_agent_private_link" {
  count       = var.enable_private_link ? 1 : 0
  name_prefix = "${var.common_prefix}agent-pl-"
  policy      = data.aws_iam_policy_document.redpanda_agent_private_link[0].json
}

resource "aws_iam_role_policy_attachment" "redpanda_agent_private_link" {
  count      = var.enable_private_link ? 1 : 0
  role       = aws_iam_role.redpanda_agent.name
  policy_arn = aws_iam_policy.redpanda_agent_private_link[0].arn
}
