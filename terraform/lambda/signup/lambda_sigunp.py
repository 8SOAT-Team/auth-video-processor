# lambda/signup/lambda_signup.py

import json
import boto3
import os

def lambda_handler(event, context):
    client = boto3.client('cognito-idp')
    body = json.loads(event['body'])

    try:
        response = client.sign_up(
            ClientId=os.environ['COGNITO_CLIENT_ID'],
            Username=body['username'],
            Password=body['password'],
            UserAttributes=[
                {"Name": "email", "Value": body['email']}
            ]
        )

        return {
            "statusCode": 201,
            "body": json.dumps({
                "message": "Usuário cadastrado com sucesso.",
                "userConfirmed": response['UserConfirmed']
            })
        }

    except client.exceptions.UsernameExistsException:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Usuário já existe"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"message": f"Erro ao cadastrar: {str(e)}"})
        }
