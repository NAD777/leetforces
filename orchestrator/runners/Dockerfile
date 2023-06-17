FROM alpine

WORKDIR /app

COPY ./orchestrator/runners/runner.py ./
COPY ./orchestrator/runners/run.sh ./
COPY ./orchestrator/runners/test.sh ./

RUN apk update
RUN apk add python3 py3-pip openjdk8
RUN pip install pyyaml
