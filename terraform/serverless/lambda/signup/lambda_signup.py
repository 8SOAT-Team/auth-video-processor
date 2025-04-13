import json
import boto3
import os

client = boto3.client('cognito-idp')

def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
        username = body["username"]
        password = body["password"]
        email = body["email"]

        response = client.sign_up(
            ClientId=os.environ["COGNITO_CLIENT_ID"],
            Username=username,
            Password=password,
            UserAttributes=[
                {"Name": "email", "Value": email}
            ]
        )

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Usuário cadastrado com sucesso.",
                "userConfirmed": response["UserConfirmed"]
            })
        }

    except client.exceptions.UsernameExistsException:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Usuário já existe"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
