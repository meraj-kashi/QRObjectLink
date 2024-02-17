######################################################################
# Create Lambda APIs 
######################################################################
# - Each API requires invoke permissions!
######################################################################

# API Lambda function - Presigned URL
resource "aws_lambda_function" "cv_digitalisering_presigned_url_api" {
  description   = "presigned url token API"
  s3_bucket     = aws_s3_bucket.cv_digitalisering_s3.id
  s3_key        = aws_s3_object.dummy_s3_object_presigned_url_api.key
  function_name = "${local.name}-presigned-url-api"
  role          = aws_iam_role.cv_digitalisering_presigned_url_lambda_api_role.arn
  handler       = "lambda_function.lambda_handler"

  lifecycle {
    ignore_changes = [
      source_code_hash,
      environment
    ]
  }

  runtime     = "python3.12"
  timeout     = 900
  memory_size = 256

  tags = local.tags

  depends_on = [
    aws_iam_role_policy_attachment.cv_digitalisering_attach_presigned_url_policy_to_role,
    aws_s3_bucket.cv_digitalisering_s3,
    aws_s3_object.dummy_s3_object_presigned_url_api,
    aws_cloudwatch_log_group.cv_digitalisering_presigned_url_cw_log_group
  ]
}

# API Lambda function permission - presigned_url
resource "aws_lambda_permission" "apigw_invoke_presigned_url_get" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cv_digitalisering_presigned_url_api.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.cv_digitalisering_apigw.id}/*/${aws_api_gateway_method.cv_digitalisering_apigw_presigned_url_api_method_get.http_method}${aws_api_gateway_resource.cv_digitalisering_apigw_presigned_url_api_resource.path}"
}

# API Lambda function - Presigned URL
resource "aws_lambda_function" "cv_digitalisering_qr_code_api" {
  description   = "qr code generator API"
  s3_bucket     = aws_s3_bucket.cv_digitalisering_s3.id
  s3_key        = aws_s3_object.dummy_s3_object_qr_code_api.key
  function_name = "${local.name}-qr-code-api"
  role          = aws_iam_role.cv_digitalisering_qr_code_lambda_api_role.arn
  handler       = "lambda_function.lambda_handler"

  lifecycle {
    ignore_changes = [
      source_code_hash,
      environment
    ]
  }

  runtime     = "python3.12"
  timeout     = 900
  memory_size = 256

  tags = local.tags

  depends_on = [
    aws_iam_role_policy_attachment.cv_digitalisering_attach_qr_code_policy_to_role,
    aws_s3_bucket.cv_digitalisering_s3,
    aws_s3_object.dummy_s3_object_qr_code_api,
    aws_cloudwatch_log_group.cv_digitalisering_qr_code_cw_log_group
  ]
}

# API Lambda function permission - QR Code Generator
resource "aws_lambda_permission" "apigw_invoke_qr_code_get" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cv_digitalisering_qr_code_api.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${var.account_id}:${aws_api_gateway_rest_api.cv_digitalisering_apigw.id}/*/${aws_api_gateway_method.cv_digitalisering_apigw_qr_code_api_method_get.http_method}${aws_api_gateway_resource.cv_digitalisering_apigw_qr_code_api_resource.path}"
}
