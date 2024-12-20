# Lambda function API to S3
resource "aws_lambda_function" "api_to_s3" {
  filename      = "scripts/api_to_s3.zip"
  function_name = "apiToS3"
  role          = aws_iam_role.apitos3_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.13"
  timeout       = 30
  memory_size   = 128

  environment {
    variables = {
      BUCKET_NAME = "demo-lakehouse-raw-zone"
    }
  }
}

# Lambda function dataCleaning
resource "aws_lambda_function" "data_cleaning" {
  filename      = "scripts/data_cleaning.zip"
  function_name = "data_cleaning"
  role          = aws_iam_role.apitos3_role.arn
  handler       = "data_cleaning.lambda_handler"
  runtime       = "python3.13"
  timeout       = 30
  memory_size   = 128

  environment {
    variables = {
      SOURCE_BUCKET      = aws_s3_bucket.raw_zone.id
      DESTINATION_BUCKET = aws_s3_bucket.processed_zone.id
    }
  }
}