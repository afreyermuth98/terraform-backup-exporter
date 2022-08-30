data "archive_file" "backup_exporter" {
  type        = "zip"
  source_file = "sources/terraform-backup-exporter.py"
  output_path = "sources/terraform-backup-exporter.zip"
}

resource "aws_lambda_function" "backup_exporter" {
  filename      = data.archive_file.backup_exporter.output_path
  function_name = "Backup-Exporter"
  description   = "This script will export the backup infos of AWS Backup"

  role             = aws_iam_role.lambda.arn
  handler          = "terraform-backup-exporter.lambda_handler"
  source_code_hash = data.archive_file.backup_exporter.output_base64sha256
  runtime          = var.runtime
  memory_size      = var.memory_size
  timeout          = var.timeout

  environment {
    variables = {
      SNS_TOPIC_ARN    = aws_sns_topic.backup_topic.arn
      BUCKET           = aws_s3_bucket.backup_bucket.bucket
      DAYS_TO_RETRIEVE = var.days_to_retrieve
    }
  }

  depends_on = [data.archive_file.backup_exporter]

}


