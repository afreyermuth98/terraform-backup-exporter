resource "aws_kms_alias" "backup_alias" {
  name          = "alias/backup-key"
  target_key_id = aws_kms_key.backup_key.key_id
}


resource "aws_kms_key" "backup_key" {
  description = "KMS KEY for backup exporter lambda"
  policy      = data.aws_iam_policy_document.kms_key_policy.json
}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = [aws_s3_bucket.backup_bucket.arn]
    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.lambda.arn,
      ]
    }
  }

}