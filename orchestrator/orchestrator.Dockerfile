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

COPY ./orchestrator/runner.py ./
COPY ./orchestrator/judge_types.py ./
COPY ./orchestrator/run.sh ./
COPY ./orchestrator/test.sh ./
COPY ./orchestrator/runner.Dockerfile ./
