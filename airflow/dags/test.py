from datetime import datetime, timedelta
from airflow import DAG
from airflow.sdk import task
from airflow.models import Connection

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
    'example_dag',
    default_args=default_args,
    description='A simple example DAG',
    schedule=timedelta(days=1),
    start_date=datetime(2024, 1, 1),
    catchup=False
) as dag:
    
    @task
    def print_aws_connection():
        # Get AWS connection details from Airflow
        aws_conn = Connection.get_connection_from_secrets('aws_default')
        print("AWS Connection Details:")
        print(f"Connection Type: {aws_conn.conn_type}")
        print(f"Host: {aws_conn.host}")
        print(f"Login: {aws_conn.login}")
        print(f"Password: {aws_conn.password}")
        print(f"Extra: {aws_conn.extra}")
        return aws_conn.extra
    
    # Execute the task
    print_aws_connection()
