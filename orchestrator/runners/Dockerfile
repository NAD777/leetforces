FROM alpine

RUN apk update
# RUN apk add --no-cache make gcc linux-headers libc-dev python3 python3-dev musl-dev
# RUN apk add python3 py3-pip
RUN apk add python3 py3-pip openjdk8
RUN pip install pyyaml
WORKDIR /app

ADD ./orchestrator/runners/test_data ./test_data
ADD ./orchestrator/runners/runner.py ./
ADD ./orchestrator/runners/run.sh ./
ADD ./problem_set/master_solutions/ ./solutions/
ADD ./configs/ ./configs/