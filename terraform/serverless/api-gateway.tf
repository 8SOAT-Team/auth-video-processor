resource "aws_apigatewayv2_api" "http_api" {
  name          = "http-api-auth-service"
  protocol_type = "HTTP"
  description   = "HTTP API Gateway para autenticação"
}

resource "aws_apigatewayv2_integration" "login_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.login.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "signup_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.signup.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "login_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /login"
  target    = "integrations/${aws_apigatewayv2_integration.login_lambda_integration.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "signup_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /signup"
  target    = "integrations/${aws_apigatewayv2_integration.signup_lambda_integration.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
  depends_on = [
    aws_apigatewayv2_route.login_route,
    aws_apigatewayv2_route.signup_route
  ]
}

resource "aws_lambda_permission" "allow_api_gateway_login" {
  statement_id  = "AllowInvokeLoginLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*"
}

resource "aws_lambda_permission" "allow_api_gateway_signup" {
  statement_id  = "AllowInvokeSignupLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.signup.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*"
}
