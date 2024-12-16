# Athena workgroup with cost controls
resource "aws_athena_workgroup" "main" {
  name = "demo_lakehouse_workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.processed_zone.bucket}/athena-output/"
    }

    bytes_scanned_cutoff_per_query = 1073741824 # 1GB limit per query
  }
}

