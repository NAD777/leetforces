FROM python:3.9.16

RUN pip install flask pyyaml

WORKDIR /app

ADD ./runners/test_data/ ./test_data
ADD ./orchestrator/app.py .
ADD ./orchestrator/test_data_generator.py .