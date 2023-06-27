FROM alpine:3.18.2

RUN apk update
RUN apk add python3 py3-pip openjdk8 ufw
RUN pip install pyyaml

WORKDIR /app

COPY ./runners/runner.py ./
COPY ./runners/judge_types.py ./
COPY ./runners/run.sh ./
COPY ./runners/test.sh ./

ENTRYPOINT python -u runner.py
