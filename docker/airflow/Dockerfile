FROM apache/airflow:2.8.1-python3.11

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git gnupg unixodbc-dev \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc -o /tmp/microsoft.asc \
    && gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg /tmp/microsoft.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" \
        > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 \
    && rm -rf /var/lib/apt/lists/* /tmp/microsoft.asc

USER airflow

COPY docker/airflow/requirements.txt /tmp/requirements.txt

RUN python -m venv /home/airflow/project-venv \
    && env -u PIP_USER /home/airflow/project-venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt
