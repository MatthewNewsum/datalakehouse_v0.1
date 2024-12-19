# Lambda function API to S3
resource "aws_lambda_function" "api_to_s3" {
  filename         = "scripts/api_to_s3.zip"
  function_name    = "apiToS3"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.13"
  timeout         = 30
  memory_size     = 128

  environment {
    variables = {
      BUCKET_NAME = "demo-lakehouse-raw-zone"
    }
  }
}