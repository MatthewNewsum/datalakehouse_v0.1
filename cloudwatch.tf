# CloudWatch Metric Alarms for cost monitoring
resource "aws_sns_topic" "cost_alerts" {
  name = "lakehouse-cost-alerts"
}

# CloudWatch Budget Alerts
resource "aws_budgets_budget" "monthly" {
  provider = aws.us-east-1
  
  name              = "lakehouse-monthly-budget"
  budget_type       = "COST"
  limit_amount      = "100"
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2024-01-01_00:00"

  notification {
    comparison_operator       = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_sns_topic_arns = [aws_sns_topic.cost_alerts.arn]
  }
}

# CloudWatch Alarm for Redshift usage
resource "aws_cloudwatch_metric_alarm" "redshift_usage" {
  alarm_name          = "redshift-high-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/Redshift"
  period              = "300"
  statistic           = "Average"
  threshold           = "75"
  alarm_description   = "This metric monitors Redshift CPU usage"
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    ClusterIdentifier = aws_redshift_cluster.demo.cluster_identifier
  }
}

# CloudWatch Dashboard
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
            ["AWS/Redshift", "CPUUtilization", "ClusterIdentifier", aws_redshift_cluster.demo.cluster_identifier],
            ["AWS/Athena", "TotalExecutionTime", "WorkGroup", aws_athena_workgroup.main.name]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-1"
          title  = "Compute Usage"
        }
      }
    ]
  })
}