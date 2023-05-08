FROM alpine

RUN apk update
RUN apk add python3 py3-pip openjdk8
RUN pip install pyyaml
WORKDIR /app

ADD ./orchestrator/runners/runner.py ./
ADD ./orchestrator/runners/run.sh ./
ADD ./orchestrator/runners/test.sh ./