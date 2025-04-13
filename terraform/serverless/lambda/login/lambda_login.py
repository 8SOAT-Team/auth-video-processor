import json
import boto3
import os

client = boto3.client('cognito-idp')

def lambda_handler(event, context):
    print("Evento recebido:", event)

    body = json.loads(event.get('body', '{}'))

    username = body.get('username')
    password = body.get('password')

    if not username or not password:
        return {
            "statusCode": 400,
            "body": json.dumps({"message": "Credenciais ausentes."})
        }

    try:
        response = client.initiate_auth(
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': username,
                'PASSWORD': password
            },
            ClientId=os.environ['COGNITO_CLIENT_ID']
        )

        return {
            "statusCode": 200,
            "body": json.dumps({
                "access_token": response['AuthenticationResult']['AccessToken'],
                "id_token": response['AuthenticationResult']['IdToken'],
                "refresh_token": response['AuthenticationResult']['RefreshToken']
            })
        }

    except client.exceptions.UserNotFoundException:
        return {
            "statusCode": 404,
            "body": json.dumps({"message": "Usuário não encontrado"})
        }
    except client.exceptions.UserNotConfirmedException:
        return {
            "statusCode": 403,
            "body": json.dumps({"message": "Usuário não confirmado"})
        }
    except client.exceptions.NotAuthorizedException:
        return {
            "statusCode": 401,
            "body": json.dumps({"message": "Usuário ou senha inválidos"})
        }
    except Exception as e:
        print("Erro ao autenticar:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"message": f"Erro ao autenticar: {str(e)}"})
        }
