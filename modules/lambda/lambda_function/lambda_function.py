import boto3
import os

def client():
    return boto3.client('s3')



def lambda_handler(event, context):
    s3_client = client()
    
    
    message = f" Bucket crudo{os.getenv('RAW_BUCKET_NAME', 'UNKNOWN_BUCKET')}, bucket refined{os.getenv('PROCESSED_BUCKET_NAME', 'UNKNOWN_BUCKET')}   "
    print(message)
    return {
        'statusCode': 200,
    }

