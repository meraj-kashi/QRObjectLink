# CloudWatch log group - presigned_url
resource "aws_cloudwatch_log_group" "qrobjectlink_presigned_url_cw_log_group" {
  name              = "/aws/lambda/${local.name}-presigned-url-api"
  retention_in_days = var.cw_log_retention_in_days
  tags              = local.tags
}

# CloudWatch log group - QR Code Generator
resource "aws_cloudwatch_log_group" "qrobjectlink_qr_code_cw_log_group" {
  name              = "/aws/lambda/${local.name}-qr-code-api"
  retention_in_days = var.cw_log_retention_in_days
  tags              = local.tags
}
