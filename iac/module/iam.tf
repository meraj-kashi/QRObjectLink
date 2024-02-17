############################################################################################################
# # presigned_url Lambda IAM Role
############################################################################################################
resource "aws_iam_role" "cv_digitalisering_presigned_url_lambda_api_role" {
  name               = "${local.name}-presigned-url-api-handler"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  tags               = local.tags
}

# Attach Presigned URL policy to Presigned URL role
resource "aws_iam_role_policy_attachment" "cv_digitalisering_attach_presigned_url_policy_to_role" {
  role       = aws_iam_role.cv_digitalisering_presigned_url_lambda_api_role.name
  policy_arn = aws_iam_policy.default_lambda_api_policy.arn
}

# Default Lambda API IAM Policy
# - Copy this block and create a new policy if the Lambda API needs access outside default (S3 storage and CloudWatch logging)
resource "aws_iam_policy" "default_lambda_api_policy" {
  name        = "${local.name}-default-lambda-api"
  description = "Granting access to s3 and CloudWatch logging for Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "LambdaFunctionS3BucketAccess",
        Action = [
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketVersions"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.cv_digitalisering_s3.arn}",
          "${aws_s3_bucket.cv_digitalisering_s3.arn}/*"
        ]
      },
      {
        "Sid" : "LambdaFunctionCloudWatchAccess",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        "Sid" : "S3ObjectStoreAccess",
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetBucketLocation",
          "s3:PutLifecycleConfiguration"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_store}",
          "arn:aws:s3:::${var.s3_bucket_store}/*"
        ]
      }
    ]
  })

  tags = local.tags

  depends_on = [
    aws_s3_bucket.cv_digitalisering_s3
  ]
}

############################################################################################################
# # QR Code Generator Lambda IAM Role
############################################################################################################

# qr_code Lambda IAM Role
resource "aws_iam_role" "cv_digitalisering_qr_code_lambda_api_role" {
  name               = "${local.name}-qr-code-api-handler"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  tags               = local.tags
}

# Attach QR Code Generator policy to QR Code Generator role
resource "aws_iam_role_policy_attachment" "cv_digitalisering_attach_qr_code_policy_to_role" {
  role       = aws_iam_role.cv_digitalisering_qr_code_lambda_api_role.name
  policy_arn = aws_iam_policy.default_lambda_api_policy.arn
}
