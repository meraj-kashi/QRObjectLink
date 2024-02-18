resource "aws_cognito_user_pool" "qrobjectlink_user_pool" {
  name = "${local.name}-user-pool"
}

resource "aws_cognito_user_pool_client" "qrobjectlink_client" {
  name                = "client"
  user_pool_id        = aws_cognito_user_pool.qrobjectlink_user_pool.id
  explicit_auth_flows = var.cognito_auth_flows
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
  access_token_validity  = 5
  id_token_validity      = 5
  refresh_token_validity = 1
}
