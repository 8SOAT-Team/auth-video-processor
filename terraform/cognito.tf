resource "aws_cognito_user_pool" "user_pool" {
  name = "auth-service-user-pool"

  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

# App Client (sem secret, para uso em Lambda)
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "auth-service-app-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  generate_secret            = false
  explicit_auth_flows        = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
  prevent_user_existence_errors = true
}