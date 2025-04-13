import json
import boto3
import os

# Inicializa o cliente do Cognito
client = boto3.client('cognito-idp')

def lambda_handler(event, context):
    try:
        # Valida o que veio no evento (exemplo de estrutura)
        print("Event recebido:", event)  # Para debug

        # Pega os parâmetros do corpo da requisição
        body = json.loads(event.get("body", "{}"))
        username = body.get("username", "")
        password = body.get("password", "")
        email = body.get("email", "")

        # Verifique se os campos obrigatórios estão presentes
        if not username or not password or not email:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Todos os campos são obrigatórios"})
            }

        # Chama o Cognito para registrar o usuário
        response = client.sign_up(
            ClientId=os.environ["COGNITO_CLIENT_ID"],
            Username=username,
            Password=password,
            UserAttributes=[
                {"Name": "email", "Value": email}
            ]
        )

        # Retorna sucesso
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
        print(f"Erro: {str(e)}")  # Para debug
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
