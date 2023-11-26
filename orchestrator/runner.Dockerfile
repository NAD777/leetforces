FROM alpine:3.18.2

RUN apk update
RUN apk add python3 py3-pip openjdk8
RUN pip install pyyaml

WORKDIR /app

COPY ./orchestrator/runner.py ./
COPY ./orchestrator/judge_types.py ./
COPY ./orchestrator/run.sh ./
COPY ./orchestrator/test.sh ./
COPY ./orchestrator/runner.Dockerfile ./

# RUN chmod +rw ../app
# RUN mkdir submissions test_data
# RUN chmod +w submissions test_data

# RUN adduser -G userrr
# USER userrr

ENTRYPOINT python -u runner.py
