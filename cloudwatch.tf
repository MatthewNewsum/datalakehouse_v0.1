resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "lakehouse-cost-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/Athena", "TotalExecutionTime", "WorkGroup", aws_athena_workgroup.main.name]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
        }
      }
    ]
  })
}

# CloudWatch log group for Lambda function
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/apiToS3"
  retention_in_days = 14
}