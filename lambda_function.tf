# Lambda function API to S3
resource "aws_lambda_function" "api_to_s3" {
  #   filename      = "scripts/api_to_s3.zip"
  s3_bucket     = aws_s3_bucket.lambda_code.id
  s3_key        = aws_s3_object.api_to_s3_code.key
  function_name = "apiToS3"
  role          = aws_iam_role.api_to_s3_role.arn
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
  s3_bucket     = aws_s3_bucket.lambda_code.id
  s3_key        = aws_s3_object.data_cleaning_code.key
  function_name = "data_cleaning"
  role          = aws_iam_role.api_to_s3_role.arn
  handler       = "data_cleaning.lambda_handler"
  runtime       = "python3.12"
  layers        = ["arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python312:15"]
  timeout       = 30
  memory_size   = 128
  environment {
    variables = {
      SOURCE_BUCKET      = aws_s3_bucket.raw_zone.id
      DESTINATION_BUCKET = aws_s3_bucket.processed_zone.id
    }
  }
}


# # Upload Python script to S3
# resource "aws_s3_object" "data_cleaning_script" {
#   bucket = aws_s3_bucket.raw_zone.id
#   key    = "scripts/data_cleaning.py"
#   source = "${path.module}/scripts/data_cleaning.py"
#   etag   = filemd5("${path.module}/scripts/data_cleaning.py")
# }