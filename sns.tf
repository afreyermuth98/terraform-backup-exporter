

resource "aws_sns_topic" "backup_topic" {
  name              = "backup-topic"
  kms_master_key_id = aws_kms_alias.backup_alias.name


  policy = <<POLICY
  {
      "Version":"2012-10-17",
      "Statement":[{
          "Effect": "Allow",
          "Principal": {"Service":"s3.amazonaws.com"},
          "Action": "SNS:Publish",
          "Resource":  "arn:aws:sns:${var.region}:${local.account_id}:backup-topic",
          "Condition":{
              "ArnLike":{"aws:SourceArn":"${aws_iam_role.lambda.arn}"}
          }
      }]
  }
  POLICY
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.backup_topic.arn
  protocol  = "email"
  endpoint  = var.subscriber_email
}