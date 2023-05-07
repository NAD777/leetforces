FROM python:3.9.16

RUN pip install flask pyyaml requests

WORKDIR /app

ADD ./orchestrator/app.py .
ADD ./orchestrator/test_runner.py .