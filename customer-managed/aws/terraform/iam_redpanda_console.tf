# Redpanda Console IAM policy & role for secrets manager access.

data "aws_iam_policy_document" "console_secrets_manager" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:CreateSecret",
      "secretsmanager:DeleteSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:RestoreSecret",
      "secretsmanager:RotateSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource",
      "secretsmanager:UpdateSecret"
    ]
    resources = [
      "arn:aws:secretsmanager:${var.region}:*:secret:redpanda/*/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      # The following secretsmanager actions do not support resource types
      # https://docs.aws.amazon.com/service-authorization/latest/reference/list_awssecretsmanager.html
      "secretsmanager:ListSecrets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "console_secrets_manager" {
  name_prefix = "${var.common_prefix}-console-scrts-mgr-"
  path        = "/"
  description = "Redpanda console - grant create/update/delete access to secrets manager"
  policy      = data.aws_iam_policy_document.console_secrets_manager.json
}

data "aws_iam_policy_document" "console_secrets_manager_trust" {
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
        variable = "aws:RequestTag/${condition.key}"
        values   = [condition.value]
      }
    }
  }
}

resource "aws_iam_role" "console_secrets_manager_redpanda" {
  name_prefix        = "${var.common_prefix}-console-scrts-mgr-"
  assume_role_policy = data.aws_iam_policy_document.console_secrets_manager_trust.json
}

resource "aws_iam_role_policy_attachment" "console_secrets_manager_redpanda" {
  role       = aws_iam_role.console_secrets_manager_redpanda.name
  policy_arn = aws_iam_policy.console_secrets_manager.arn
}
