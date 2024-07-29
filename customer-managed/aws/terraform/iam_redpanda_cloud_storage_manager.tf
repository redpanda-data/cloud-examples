data "aws_iam_policy_document" "redpanda_cloud_storage_manager" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.redpanda_cloud_storage.arn,
      "${aws_s3_bucket.redpanda_cloud_storage.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "redpanda_cloud_storage_manager_trust" {
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

resource "aws_iam_policy" "redpanda_cloud_storage_manager" {
  name_prefix = "${var.common_prefix}-cloud-storage-manager-"
  policy      = data.aws_iam_policy_document.redpanda_cloud_storage_manager.json
}

resource "aws_iam_role" "redpanda_cloud_storage_manager" {
  name_prefix        = "${var.common_prefix}-cloud-storage-manager-"
  assume_role_policy = data.aws_iam_policy_document.redpanda_cloud_storage_manager_trust.json
}

resource "aws_iam_role_policy_attachment" "redpanda_cloud_storage_manager" {
  role       = aws_iam_role.redpanda_cloud_storage_manager.name
  policy_arn = aws_iam_policy.redpanda_cloud_storage_manager.arn
}
