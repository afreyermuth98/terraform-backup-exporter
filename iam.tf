resource "aws_iam_role" "lambda" {
  name = "lambda-backup-role"

  path = "/"

  assume_role_policy = data.aws_iam_policy_document.aws_iam_role_assume_role_policy.json
}

data "aws_iam_policy_document" "aws_iam_role_assume_role_policy" {
  statement {
    sid = "sts"
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com"
      ]
    }
  }
}


resource "aws_iam_role_policy" "lambda" {
  name = "lambda-backup-role-policy"
  role = aws_iam_role.lambda.id

  policy = data.aws_iam_policy_document.lambda_policy_document.json
}

data "aws_iam_policy_document" "lambda_policy_document" {
  statement {
    sid = "sns"
    actions = [
      "sns:Publish"
    ]
    effect    = "Allow"
    resources = [aws_sns_topic.backup_topic.arn]
  }

  statement {
    sid = "LoggingPolicy"
    actions = [
      "logs:CreateLogGroup",
      "logs:DescribeLogStreams",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    sid = "BackupPolicy"
    actions = [
      "backup:List*",
      "backup-storage:MountCapsule"
    ]
    effect    = "Allow"
    resources = ["*"]
  }


  statement {
    sid = "BucketPolicy"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:AbortMultipartUpload"
    ]
    effect    = "Allow"
    resources = [
        "${aws_s3_bucket.backup_bucket.arn}",
        "${aws_s3_bucket.backup_bucket.arn}/*",
    ]
  }

  statement {
    sid = "kms"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    effect    = "Allow"
    resources = [aws_kms_key.backup_key.arn]
  }

}
