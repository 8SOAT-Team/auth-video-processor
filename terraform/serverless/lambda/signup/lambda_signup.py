import json
import boto3
import os
import psycopg2

def lambda_handler(event, context):
    client = boto3.client('cognito-idp')

    body = json.loads(event['body'])

    username = body.get('username')
    password = body.get('password')
    email = body.get('email')

    if not username or not password or not email:
        return {"statusCode": 400, "body": json.dumps({"message": "Dados obrigatórios ausentes."})}

    try:
        # Criação do usuário no Cognito
        response = client.sign_up(
            ClientId=os.environ['COGNITO_CLIENT_ID'],
            Username=username,
            Password=password,
            UserAttributes=[{"Name": "email", "Value": email}]
        )

        # (Opcional) salvar no banco de dados
        conn = psycopg2.connect(
            host=os.environ['DB_HOST'],
            dbname=os.environ['DB_NAME'],
            user=os.environ['DB_USER'],
            password=os.environ['DB_PASS']
        )
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO users (username, email, cognito_sub) VALUES (%s, %s, %s)",
            (username, email, response["UserSub"])
        )
        conn.commit()
        cur.close()
        conn.close()

        return {
            "statusCode": 201,
            "body": json.dumps({
                "message": "Usuário cadastrado com sucesso.",
                "userConfirmed": response['UserConfirmed']
            })
        }

    except client.exceptions.UsernameExistsException:
        return {"statusCode": 400, "body": json.dumps({"message": "Usuário já existe"})}
    except Exception as e:
        return {"statusCode": 500, "body": json.dumps({"message": f"Erro: {str(e)}"})}
