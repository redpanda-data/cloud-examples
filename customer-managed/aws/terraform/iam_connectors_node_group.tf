data "aws_iam_policy_document" "connectors_node_group_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "connectors_node_group" {
  name_prefix           = "${var.common_prefix}-connect-"
  path                  = "/"
  force_detach_policies = true
  tags = merge(
    var.default_tags,
    {
      "redpanda-client" = "connectors"
    }
  )
  assume_role_policy = data.aws_iam_policy_document.connectors_node_group_trust.json
}

resource "aws_iam_instance_profile" "connectors_node_group" {
  name_prefix = "${var.common_prefix}-connect-"
  path        = "/"
  role        = aws_iam_role.connectors_node_group.name
  tags = merge(
    var.default_tags,
    {
      "redpanda-client" = "connectors"
    }
  )
}

data "aws_iam_policy_document" "connectors_autoscaler_policy" {
  statement {
    effect = "Allow"
    actions = [
      # The following autoscaling actions do not support resource types
      # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonec2autoscaling.html
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",

      # The following ec2 actions do not support resource types
      # https://docs.aws.amazon.com/service-authorization/latest/reference/list_amazonec2.html
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
    ]
    resources = [
      "arn:aws:autoscaling:${var.region}:${local.aws_account_id}:autoScalingGroup:*:autoScalingGroupName/redpanda-*-connect-*",
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
}

resource "aws_iam_policy" "connectors_autoscaler_policy" {
  name_prefix = "${var.common_prefix}-rp-autoscaler-"
  policy      = data.aws_iam_policy_document.connectors_autoscaler_policy.json
}

resource "aws_iam_role_policy_attachment" "connectors_node_group" {
  for_each = {
    "1" = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    "2" = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    "3" = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    "4" = aws_iam_policy.connectors_autoscaler_policy.arn
  }
  policy_arn = each.value
  role       = aws_iam_role.connectors_node_group.name
}
