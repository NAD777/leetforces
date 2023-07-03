FROM alpine:3.18.2

RUN apk update
RUN apk add python3 py3-pip
RUN pip install flask pyyaml requests prometheus_flask_exporter docker

WORKDIR /app

# Essential for running
COPY ./orchestrator/app.py .
COPY ./orchestrator/dockerapi.py .
COPY ./orchestrator/orchestrator.py .
COPY ./orchestrator/decorators.py .
COPY ./orchestrator/judge_types.py .
COPY ./configs/ ./configs/

COPY ./orchestrator/runner.py ./runners/
COPY ./orchestrator/judge_types.py ./runners/
COPY ./orchestrator/run.sh ./runners/
COPY ./orchestrator/test.sh ./runners/
COPY ./orchestrator/runner.Dockerfile ./runners/
