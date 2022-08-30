resource "aws_cloudwatch_event_rule" "cloudwatch_exporter" {
  count               = var.lambda_schedule ? 1 : 0
  name                = "cloudwatch-event-rule-lambda-backup-exporter"
  description         = "Triggers the security hub exporter lambda"
  schedule_expression = "cron(0 3 * * ? *)" // Each day at 3pm
}

resource "aws_cloudwatch_event_target" "cloudwatch_exporter_target" {
  count     = var.lambda_schedule ? 1 : 0
  rule      = aws_cloudwatch_event_rule.cloudwatch_exporter[0].name
  target_id = "lambda"
  arn       = aws_lambda_function.backup_exporter.function_name
}

resource "aws_lambda_permission" "allow_cloudwatch_exporter" {
  count         = var.lambda_schedule ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backup_exporter.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cloudwatch_exporter[0].arn
}
