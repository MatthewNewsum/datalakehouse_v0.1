

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

