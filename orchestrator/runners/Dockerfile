FROM alpine

RUN apk update
RUN apk add python3 py3-pip
# RUN apk add python3 py3-pip openjdk8
RUN pip install pyyaml

WORKDIR /app

ADD ./orchestrator/runners/ ./
ADD ./problem_set/master_solutions/ ./solutions/
ADD ./orchestrator/configs/ ./configs/