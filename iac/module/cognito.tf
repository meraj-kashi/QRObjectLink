resource "aws_cognito_user_pool" "cv_digitalisering_user_pool" {
  name = "${local.name}-user-pool"
}

resource "aws_cognito_user_pool_client" "cv_digitalisering_client" {
  name         = "client"
  user_pool_id = aws_cognito_user_pool.cv_digitalisering_user_pool.id
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}
