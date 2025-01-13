# Glue role and policies
resource "aws_iam_role" "glue_role" {
  name = "GlueETLRole"

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

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3" {
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
          aws_s3_bucket.processed_zone.arn, # Fixed: Removed quotes
          "${aws_s3_bucket.processed_zone.arn}/*"
        ]
      }
    ]
  })
}

# resource "aws_iam_role_policy" "glue_s3" {
#   name = "GlueS3Policy"
#   role = aws_iam_role.glue_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:DeleteObject",
#           "s3:ListBucket"
#         ]
#         Resource = [
#           aws_s3_bucket.raw_zone.arn,
#           "${aws_s3_bucket.raw_zone.arn}/*",
#           "aws_s3_bucket.processed_zone.arn",
#           "${aws_s3_bucket.processed_zone.arn}/*"
#         ]
#       }
#     ]
#   })
# }

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

# IAM role for api to S3 Lambda function
resource "aws_iam_role" "api_to_s3_role" {
  name = "api_to_s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Custom policy for CloudWatch Logs
resource "aws_iam_role_policy" "apitos3_cloudwatch" {
  name = "AWSLambdaBasicExecutionRole-e89d77b3-20ed-496b-b116-d0d221ab2ffb"
  role = aws_iam_role.api_to_s3_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "logs:CreateLogGroup"
        Resource = "arn:aws:logs:us-east-1:841162683310:*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:us-east-1:841162683310:log-group:/aws/lambda/apiToS3:*"
        ]
      }
    ]
  })
}

# Attach AmazonS3FullAccess managed policy
resource "aws_iam_role_policy_attachment" "apitos3_s3_full_access" {
  role       = aws_iam_role.api_to_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}