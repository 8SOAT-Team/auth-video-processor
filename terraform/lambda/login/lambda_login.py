# lambda/login/lambda_login.py

import json
import boto3
import os

def lambda_handler(event, context):
    client = boto3.client('cognito-idp')
    body = json.loads(event['body'])

    try:
        response = client.initiate_auth(
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': body['username'],
                'PASSWORD': body['password']
            },
            ClientId=os.environ['COGNITO_CLIENT_ID']
        )

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Login realizado com sucesso.",
                "tokens": response['AuthenticationResult']
            })
        }

    except client.exceptions.NotAuthorizedException:
        return {
            "statusCode": 401,
            "body": json.dumps({"message": "Credenciais inválidas"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"message": f"Erro ao autenticar: {str(e)}"})
        }
