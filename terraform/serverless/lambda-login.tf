resource "aws_lambda_function" "login" {
  function_name = "login-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_login.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_login.zip"
  source_code_hash = filebase64sha256("lambda_login.zip")

  environment {
    variables = {
      COGNITO_CLIENT_ID = aws_cognito_user_pool_client.user_pool_client.id
    }
  }

  vpc_config {
    subnet_ids         = data.terraform_remote_state.network.outputs.public_subnet_ids
    security_group_ids = [data.terraform_remote_state.network.outputs.aws_security_group_id]
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_policy_attachment]
}
