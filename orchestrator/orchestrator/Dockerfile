FROM alpine

WORKDIR /app

# Essential for running
COPY ./orchestrator/orchestrator/app.py .
COPY ./orchestrator/orchestrator/test_runner.py .
COPY ./orchestrator/orchestrator/dockerapi.py .
COPY ./configs/ ./configs/

COPY ./orchestrator/runners ./runners

RUN apk update
RUN apk add python3 py3-pip
RUN pip install flask pyyaml requests prometheus_flask_exporter docker
