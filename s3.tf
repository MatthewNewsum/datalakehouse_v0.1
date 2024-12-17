# Add AWS Caller Identity data source
data "aws_caller_identity" "current" {}

# S3 buckets for different layers
resource "aws_s3_bucket" "raw_zone" {
  bucket = "demo-lakehouse-raw-zone"
}

resource "aws_s3_bucket" "processed_zone" {
  bucket = "demo-lakehouse-processed-zone"
}

resource "aws_s3_bucket" "curated_zone" {
  bucket = "demo-lakehouse-curated-zone"
}

# Enable versioning and lifecycle rules for all buckets
resource "aws_s3_bucket_versioning" "raw_versioning" {
  bucket = aws_s3_bucket.raw_zone.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle rules for raw zone
resource "aws_s3_bucket_lifecycle_configuration" "raw_lifecycle" {
  bucket = aws_s3_bucket.raw_zone.id

  rule {
    id     = "cleanup_old_data"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    expiration {
      days = 90
    }
  }
}

# Similar lifecycle rules for processed and curated zones
resource "aws_s3_bucket_lifecycle_configuration" "processed_lifecycle" {
  bucket = aws_s3_bucket.processed_zone.id

  rule {
    id     = "archive_old_data"
    status = "Enabled"

    transition {
      days          = 60
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}