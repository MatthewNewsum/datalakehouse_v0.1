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