import boto3
import os
import urllib.parse

s3 = boto3.client("s3")

SOURCE_BUCKET = os.environ["RAW_BUCKET_NAME"]
DESTINATION_BUCKET = os.environ["PROCESSED_BUCKET_NAME"]

def lambda_handler(event, context):
    try:

        source_key = urllib.parse.unquote_plus(
            event["Records"][0]["s3"]["object"]["key"]
        )

        print(f"Archivo recibido: {source_key}")
        print(f"Origen: {SOURCE_BUCKET}")
        print(f"Destino: {DESTINATION_BUCKET}")

        # Copiar el archivo al bucket limpio
        s3.copy_object(
            Bucket=DESTINATION_BUCKET,
            Key=source_key,
            CopySource={
                "Bucket": SOURCE_BUCKET,
                "Key": source_key
            }
        )

        print("Archivo copiado correctamente")

        return {
            "statusCode": 200,
            "body": f"Archivo {source_key} copiado a {DESTINATION_BUCKET}"
        }

    except Exception as e:
        print(f"Error durante la copia: {str(e)}")
        raise e