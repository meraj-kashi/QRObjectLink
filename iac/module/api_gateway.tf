# REST API Gateway 
resource "aws_api_gateway_rest_api" "qrobjectlink_apigw" {
  name        = local.name
  description = "REST API Gateway"
  tags        = local.tags
}

// API Gateway path mapping
/*
resource "aws_api_gateway_base_path_mapping" "qrobjectlink_apigw_path_mapping" {
  api_id      = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  stage_name  = aws_api_gateway_deployment.qrobjectlink_deployment.stage_name
  domain_name = aws_api_gateway_domain_name.qrobjectlink_apigw_domain.domain_name
}
*/

# REST API's parent route - /api/%nameofapi%
resource "aws_api_gateway_resource" "qrobjectlink_apigw_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  parent_id   = aws_api_gateway_rest_api.qrobjectlink_apigw.root_resource_id
  path_part   = "api"
}

# Authorizer API Gateway
resource "aws_api_gateway_authorizer" "qrobjectlink_apigw_authorizer" {
  name            = "${local.name}-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.authorizationToken"
  provider_arns   = [aws_cognito_user_pool.qrobjectlink_user_pool.arn]
  depends_on = [
    aws_cognito_user_pool.qrobjectlink_user_pool
  ]
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "qrobjectlink_deployment" {
  rest_api_id       = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  stage_name        = var.environment
  stage_description = "Deployed at ${timestamp()}"

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.qrobjectlink_apigw.body,
      aws_api_gateway_authorizer.qrobjectlink_apigw_authorizer.id,
      aws_api_gateway_method.qrobjectlink_apigw_presigned_url_api_method_get.id,
      aws_api_gateway_integration.qrobjectlink_apigw_presigned_url_api_integration_get.id,
      aws_api_gateway_resource.qrobjectlink_apigw_presigned_url_api_resource.id,
      aws_api_gateway_method.qrobjectlink_apigw_qr_code_api_method_get.id,
      aws_api_gateway_integration.qrobjectlink_apigw_qr_code_api_integration_get.id,
      aws_api_gateway_resource.qrobjectlink_apigw_qr_code_api_resource.id,
    ]))
  }

  depends_on = [
    aws_api_gateway_method.qrobjectlink_apigw_presigned_url_api_method_get,
    aws_api_gateway_integration.qrobjectlink_apigw_presigned_url_api_integration_get,
    aws_api_gateway_rest_api.qrobjectlink_apigw,
    aws_api_gateway_authorizer.qrobjectlink_apigw_authorizer,
    aws_api_gateway_resource.qrobjectlink_apigw_presigned_url_api_resource,
    aws_api_gateway_method.qrobjectlink_apigw_qr_code_api_method_get,
    aws_api_gateway_integration.qrobjectlink_apigw_qr_code_api_integration_get,
    aws_api_gateway_resource.qrobjectlink_apigw_qr_code_api_resource,
  ]

  lifecycle {
    create_before_destroy = true
  }
}

############################################################################################################
# APIs request validators
############################################################################################################
resource "aws_api_gateway_request_validator" "qrobjectlink_apigw_request_validator" {
  name                        = "validate_request_body_and_parameters"
  rest_api_id                 = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  validate_request_body       = true
  validate_request_parameters = true
}

############################################################################################################
# APIs - Routes
############################################################################################################

# Presigned URL API route
resource "aws_api_gateway_resource" "qrobjectlink_apigw_presigned_url_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  parent_id   = aws_api_gateway_resource.qrobjectlink_apigw_api_resource.id
  path_part   = "presigned"
}

# QR Code generator API route
resource "aws_api_gateway_resource" "qrobjectlink_apigw_qr_code_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  parent_id   = aws_api_gateway_resource.qrobjectlink_apigw_api_resource.id
  path_part   = "qr-code"
}

############################################################################################################
# APIs gateway models
############################################################################################################

resource "aws_api_gateway_model" "qrobjectlink_apigw_qr_code_api_model_get" {
  rest_api_id  = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  name         = "QrCodeGeneratorGET"
  description  = "QR code generator API JSON schema for GET request"
  content_type = "application/json"

  schema = <<EOF
{
  "type": "object",
  "properties":{
        "url":{ "type": "string"}
    },
  "required":["url"]
}
EOF
}

############################################################################################################
# API Methods
############################################################################################################

# Presigned URL API method
resource "aws_api_gateway_method" "qrobjectlink_apigw_presigned_url_api_method_get" {
  rest_api_id   = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  resource_id   = aws_api_gateway_resource.qrobjectlink_apigw_presigned_url_api_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.qrobjectlink_apigw_authorizer.id
}

# QR Code generator API method
resource "aws_api_gateway_method" "qrobjectlink_apigw_qr_code_api_method_get" {
  rest_api_id   = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  resource_id   = aws_api_gateway_resource.qrobjectlink_apigw_qr_code_api_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.qrobjectlink_apigw_authorizer.id
  request_models = {
    "application/json" = aws_api_gateway_model.qrobjectlink_apigw_qr_code_api_model_get.name
  }
}

############################################################################################################
# APIs - Method response
############################################################################################################

# Presigned URL API response
resource "aws_api_gateway_method_response" "qrobjectlink_apigw_presigned_url_api_response_200_get" {
  rest_api_id = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  resource_id = aws_api_gateway_resource.qrobjectlink_apigw_presigned_url_api_resource.id
  http_method = aws_api_gateway_method.qrobjectlink_apigw_presigned_url_api_method_get.http_method
  status_code = "200"
}

# QR Code generator API response
resource "aws_api_gateway_method_response" "qrobjectlink_apigw_qr_code_api_response_200_get" {
  rest_api_id = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  resource_id = aws_api_gateway_resource.qrobjectlink_apigw_qr_code_api_resource.id
  http_method = aws_api_gateway_method.qrobjectlink_apigw_qr_code_api_method_get.http_method
  status_code = "200"
}

############################################################################################################
# APIs - Integrations
############################################################################################################

# Presigned URL API integrations 
resource "aws_api_gateway_integration" "qrobjectlink_apigw_presigned_url_api_integration_get" {
  rest_api_id             = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  resource_id             = aws_api_gateway_resource.qrobjectlink_apigw_presigned_url_api_resource.id
  http_method             = aws_api_gateway_method.qrobjectlink_apigw_presigned_url_api_method_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.qrobjectlink_presigned_url_api.invoke_arn
}

# QR Code Generator API integrations 
resource "aws_api_gateway_integration" "qrobjectlink_apigw_qr_code_api_integration_get" {
  rest_api_id             = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  resource_id             = aws_api_gateway_resource.qrobjectlink_apigw_qr_code_api_resource.id
  http_method             = aws_api_gateway_method.qrobjectlink_apigw_qr_code_api_method_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.qrobjectlink_qr_code_api.invoke_arn
}

############################################################################################################
# APIs - Integration response
############################################################################################################

# Presigned URL API integration response
resource "aws_api_gateway_integration_response" "qrobjectlink_apigw_presigned_url_api_integration_response_get" {
  rest_api_id = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  resource_id = aws_api_gateway_resource.qrobjectlink_apigw_presigned_url_api_resource.id
  http_method = aws_api_gateway_method.qrobjectlink_apigw_presigned_url_api_method_get.http_method
  status_code = aws_api_gateway_method_response.qrobjectlink_apigw_presigned_url_api_response_200_get.status_code

  depends_on = [
    aws_api_gateway_integration.qrobjectlink_apigw_presigned_url_api_integration_get
  ]
}

# QR Code Generator API integration response
resource "aws_api_gateway_integration_response" "qrobjectlink_apigw_qr_code_api_integration_response_get" {
  rest_api_id = aws_api_gateway_rest_api.qrobjectlink_apigw.id
  resource_id = aws_api_gateway_resource.qrobjectlink_apigw_qr_code_api_resource.id
  http_method = aws_api_gateway_method.qrobjectlink_apigw_qr_code_api_method_get.http_method
  status_code = aws_api_gateway_method_response.qrobjectlink_apigw_qr_code_api_response_200_get.status_code

  depends_on = [
    aws_api_gateway_integration.qrobjectlink_apigw_qr_code_api_integration_get
  ]
}
