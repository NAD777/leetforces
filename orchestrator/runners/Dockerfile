FROM alpine

RUN apk update
RUN apk add python3 py3-pip
# RUN apk add python3 py3-pip openjdk8 neovim
RUN pip install python-dotenv pyyaml

WORKDIR /app

ADD ./orchestrator/runners/ ./
ADD ./problem_set/master_solutions/ ./solutions/
ADD ./orchestrator/configs/ ./configs/

CMD [ "python", "./run_tests.py"]