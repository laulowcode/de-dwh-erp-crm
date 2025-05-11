from dotenv import load_dotenv
load_dotenv()

import boto3
from botocore.config import Config
import os

s3 = boto3.client(
    's3',
    endpoint_url=os.getenv('MINIO_ENDPOINT_URL'),
    aws_access_key_id=os.getenv('MINIO_ACCESS_KEY'),
    aws_secret_access_key=os.getenv('MINIO_SECRET_KEY'),
    config=Config(signature_version='s3v4'),
    region_name=os.getenv('MINIO_REGION_NAME')
)

try:
    s3.create_bucket(Bucket='test-bucket')
except Exception as e:
    print(f"Error creating bucket: {e}")


