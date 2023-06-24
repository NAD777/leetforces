FROM alpine

WORKDIR /app

COPY ./runners/runner.py ./
COPY ./runners/run.sh ./
COPY ./runners/test.sh ./

RUN apk update
RUN apk add python3 py3-pip openjdk8 ufw
RUN pip install pyyaml

RUN ufw allow 31337

ENTRYPOINT python -u runner.py
