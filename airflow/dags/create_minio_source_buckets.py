from datetime import datetime, timedelta
from airflow import DAG
from airflow.sdk import task
import boto3
from botocore.exceptions import ClientError
import os

# Define default arguments
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Create the DAG using context manager
with DAG(
    'create_minio_source_buckets',
    default_args=default_args,
    description='Create MinIO bucket using boto3',
    schedule=None,
    start_date=datetime(2024, 1, 1),
    catchup=False
) as dag:
    
    @task
    def test_connection():
        try:
            s3_client = boto3.client(
                's3',
                endpoint_url=os.getenv("MINIO_ENDPOINT_URL", "http://minio:9000"),
                aws_access_key_id=os.getenv("MINIO_ACCESS_KEY"),
                aws_secret_access_key=os.getenv("MINIO_SECRET_KEY"),
                region_name=os.getenv("MINIO_REGION", "us-east-1")
            )
            # Test credentials by listing buckets
            response = s3_client.list_buckets()
            print("Successfully connected to MinIO. Available buckets:", response['Buckets'])
            return True
        except ClientError as e:
            print(f"Error connecting to MinIO: {str(e)}")
            raise

    @task
    def create_crm_bucket():
        s3_client = boto3.client(
            's3',
            endpoint_url=os.getenv("MINIO_ENDPOINT_URL", "http://minio:9000"),
            aws_access_key_id=os.getenv("MINIO_ACCESS_KEY"),
            aws_secret_access_key=os.getenv("MINIO_SECRET_KEY"),
            region_name=os.getenv("MINIO_REGION", "us-east-1")
        )
        s3_client.create_bucket(Bucket="source-crm")

    @task
    def create_erp_bucket():
        s3_client = boto3.client(
            's3',
            endpoint_url=os.getenv("MINIO_ENDPOINT_URL", "http://minio:9000"),
            aws_access_key_id=os.getenv("MINIO_ACCESS_KEY"),
            aws_secret_access_key=os.getenv("MINIO_SECRET_KEY"),
            region_name=os.getenv("MINIO_REGION", "us-east-1")
        )
        s3_client.create_bucket(Bucket="source-erp")

    test_connection() >> [create_crm_bucket(), create_erp_bucket()]
