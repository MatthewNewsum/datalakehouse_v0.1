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

resource "aws_s3_bucket" "lambda_code" {
  bucket = "demo-lakehouse-lambda-code"
}

# S3 objects for Lambda code
resource "aws_s3_object" "api_to_s3_code" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = "lambda/api_to_s3.zip"
  source = "scripts/api_to_s3.zip"
}

resource "aws_s3_object" "data_cleaning_code" {
  bucket = aws_s3_bucket.lambda_code.id
  key    = "lambda/data_cleaning.zip"
  source = "scripts/data_cleaning.zip"



  # # Create a scripts folder in the lambda_code bucket
  # resource "aws_s3_object" "scripts_folder" {
  #   bucket = aws_s3_bucket.lambda_code.id
  #   key    = "scripts/"
  #   source = "/dev/null"
}

# Enable versioning and lifecycle rules for all buckets
resource "aws_s3_bucket_versioning" "raw_versioning" {
  bucket = aws_s3_bucket.raw_zone.id
  versioning_configuration {
    status = "Enabled"
  }
}



# # Create folder in raw zone bucket
# resource "aws_s3_object" "raw_zone_cta_folder" {
#   bucket = "demo-lakehouse-raw-zone"
#   key    = "cta-data/"
#   source = "/dev/null"  # Empty object for folder
# }

# # Create folder in processed zone bucket
# resource "aws_s3_object" "processed_zone_cta_folder" {
#   bucket = "demo-lakehouse-processed-zone"
#   key    = "cta-data/"
#   source = "/dev/null"  # Empty object for folder
# }

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

# Lifecycle rules for processed zone
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

# Lifecycle rules for curated zone