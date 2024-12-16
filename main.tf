# IAM Role for Glue Crawler
resource "aws_iam_role" "glue_role" {
  name = "GlueCrawlerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# Attach required policies to the Glue role
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Additional S3 access policy for Glue
resource "aws_iam_role_policy" "glue_s3_policy" {
  name = "GlueS3Policy"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.raw_zone.arn,
          "${aws_s3_bucket.raw_zone.arn}/*",
          aws_s3_bucket.processed_zone.arn,
          "${aws_s3_bucket.processed_zone.arn}/*",
          aws_s3_bucket.curated_zone.arn,
          "${aws_s3_bucket.curated_zone.arn}/*"
        ]
      }
    ]
  })
}

# Glue Database
resource "aws_glue_catalog_database" "raw" {
  name = "nyc_taxi_raw"
}

# Glue Crawler
resource "aws_glue_crawler" "raw_zone_crawler" {
  database_name = aws_glue_catalog_database.raw.name
  name          = "raw-zone-crawler"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${aws_s3_bucket.raw_zone.bucket}/nyc-taxi/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  schedule = "cron(0 */12 * * ? *)" # Run every 12 hours
}