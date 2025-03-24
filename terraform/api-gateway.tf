resource "aws_apigatewayv2_api" "http_api" {
  name          = "http-api-auth-service"
  protocol_type = "HTTP"
  description   = "HTTP API Gateway integrado com Lambda CPF Validator"
}

resource "aws_apigatewayv2_authorizer" "lambda_authorizer" {
  api_id           = aws_apigatewayv2_api.http_api.id
  name             = "cpf-authorizer"
  authorizer_type  = "REQUEST"
  authorizer_uri   = aws_lambda_function.cpf_validator.invoke_arn
  identity_sources = ["$request.header.Authorization"]
  authorizer_payload_format_version = "2.0"

  depends_on = [aws_lambda_function.cpf_validator]
}

resource "aws_lambda_permission" "http_api_gateway_authorizer_permission" {
  statement_id  = "AllowHttpApiGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cpf_validator.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.cpf_validator.invoke_arn
  payload_format_version = "2.0"

  depends_on = [aws_lambda_function.cpf_validator]
}

resource "aws_apigatewayv2_route" "cpf_auth_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /auth"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "CUSTOM"
  authorizer_id      = aws_apigatewayv2_authorizer.lambda_authorizer.id

  depends_on = [
    aws_apigatewayv2_integration.lambda_integration,
    aws_apigatewayv2_authorizer.lambda_authorizer
  ]
}

resource "aws_apigatewayv2_stage" "dev_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "dev"
  auto_deploy = true

  depends_on = [aws_apigatewayv2_route.cpf_auth_route]
}

resource "aws_lambda_permission" "http_api_gateway_invoke_lambda" {
  statement_id  = "AllowHttpApiGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cpf_validator.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*"
}
