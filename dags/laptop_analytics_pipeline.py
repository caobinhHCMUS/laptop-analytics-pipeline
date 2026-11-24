from datetime import datetime, timezone

from airflow import DAG
from airflow.operators.bash import BashOperator


PROJECT_DIR = "/opt/airflow/project"
PROJECT_PYTHON = "/home/airflow/project-venv/bin/python"
PROJECT_DBT = "/home/airflow/project-venv/bin/dbt"

with DAG(
    dag_id="laptop_analytics_pipeline",
    description="Load the local Parquet snapshot into SQL Server and build dbt models.",
    start_date=datetime(2025, 1, 1, tzinfo=timezone.utc),
    schedule=None,
    catchup=False,
    max_active_runs=1,
    tags=["laptop-analytics"],
) as dag:
    load_raw_tables = BashOperator(
        task_id="load_raw_sqlserver",
        bash_command=f"{PROJECT_PYTHON} scripts/load_to_sqlserver.py",
        cwd=PROJECT_DIR,
    )

    build_dbt_models = BashOperator(
        task_id="dbt_build",
        bash_command=(
            f"{PROJECT_DBT} build --project-dir dbt_project --profiles-dir dbt_project"
        ),
        cwd=PROJECT_DIR,
    )

    load_raw_tables >> build_dbt_models
