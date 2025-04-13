import json
import boto3
import os

client = boto3.client("cognito-idp")

def lambda_handler(event, context):
    print("Event recebido:", event)

    try:
        body = json.loads(event.get("body", "{}"))
        username = body["username"]
        password = body["password"]

        # ✅ email = username
        print("Chamando Cognito com:", {
            "client_id": os.environ.get("COGNITO_CLIENT_ID"),
            "username": username
        })

        response = client.sign_up(
            ClientId=os.environ["COGNITO_CLIENT_ID"],
            Username=username,
            Password=password,
            UserAttributes=[
                {"Name": "email", "Value": username}
            ]
        )

        print("Resposta do Cognito:", response)

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Usuário cadastrado com sucesso.",
                "userConfirmed": response.get("UserConfirmed", False)
            })
        }

    except client.exceptions.UsernameExistsException:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Usuário já existe"})
        }

    except Exception as e:
        print("Erro geral:", str(e))
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
