FROM python:3.9.16

COPY ./requirements.txt .
RUN pip install -r requirements.txt

WORKDIR /juggler

ADD . .

