resource "aws_lambda_function" "signup" {
  function_name = "signup-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_signup.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_signup.zip"
  source_code_hash = filebase64sha256("lambda_signup.zip")

  layers = ["arn:aws:lambda:us-east-1:898466741470:layer:psycopg2-py39:1"]

  environment {
    variables = {
      COGNITO_USER_POOL_ID = aws_cognito_user_pool.user_pool.id
      COGNITO_CLIENT_ID    = aws_cognito_user_pool_client.user_pool_client.id
      DB_HOST              = data.terraform_remote_state.database.outputs.rds_endpoint
      DB_NAME              = data.terraform_remote_state.database.outputs.rds_db_name
      DB_USER              = data.terraform_remote_state.database.outputs.rds_username
      DB_PASS              = data.terraform_remote_state.database.outputs.rds_password
    }
  }

  vpc_config {
    subnet_ids         = data.terraform_remote_state.network.outputs.public_subnet_ids
    security_group_ids = [data.terraform_remote_state.network.outputs.aws_security_group_id]
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}
