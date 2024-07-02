data "aws_iam_policy_document" "connectors_secrets_manager" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager:${var.region}:*:secret:redpanda/*/connectors/*"
    ]
  }
}

data "aws_iam_policy_document" "connectors_secrets_manager_trust" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]
    principals {
      identifiers = [local.aws_account_id]
      type        = "AWS"
    }
    dynamic "condition" {
      for_each = var.condition_tags
      content {
        test     = "StringEquals"
        values   = [condition.value]
        variable = "aws:RequestTag/${condition.key}"
      }
    }
  }
}

resource "aws_iam_role" "connectors_secrets_manager" {
  name_prefix        = "${var.common_prefix}connectors-scrts-mgr-"
  assume_role_policy = data.aws_iam_policy_document.connectors_secrets_manager_trust.json
}

resource "aws_iam_policy" "connectors_secrets_manager" {
  name_prefix = "${var.common_prefix}connectors-scrts-mgr-"
  path        = "/"
  description = "Redpanda connectors - grant read-only access to connectors/* secrets manager"
  policy      = data.aws_iam_policy_document.connectors_secrets_manager.json
}

resource "aws_iam_role_policy_attachment" "connectors_secrets_manager" {
  role       = aws_iam_role.connectors_secrets_manager.name
  policy_arn = aws_iam_policy.connectors_secrets_manager.arn
}
