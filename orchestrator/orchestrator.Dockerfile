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

COPY ./orchestrator/runner.py ./orchestrator/
COPY ./orchestrator/judge_types.py ./orchestrator/
COPY ./orchestrator/run.sh ./orchestrator/
COPY ./orchestrator/test.sh ./orchestrator/
COPY ./orchestrator/runner.Dockerfile ./orchestrator/
