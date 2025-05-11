from datetime import datetime, timedelta
from airflow import DAG
from airflow.sdk import task

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
    def print_hello():
        return "Hello from Airflow!"
    
    # Execute the task
    print_hello()
