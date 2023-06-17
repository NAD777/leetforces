FROM python:3.9.16

WORKDIR /app

COPY ./orchestrator/orchestrator/app.py .
COPY ./orchestrator/orchestrator/test_runner.py .
COPY ./configs/ ./configs/

RUN pip install flask pyyaml requests prometheus_flask_exporter
