from flask import Flask, request
from requests import post
from base64 import b64decode
from os import environ
from logging import basicConfig, info
from logging import DEBUG as _DEBUG
from prometheus_flask_exporter import PrometheusMetrics

from orchestrator import Orchestrator

JUGGLER = environ["JUGGLER"]
DEBUG = environ["DEBUG"]

if DEBUG == "True":
    basicConfig(level=_DEBUG)

app = Flask(__name__)
app.config.from_object(__name__)

metrics = PrometheusMetrics(app, group_by='endpoint')

metrics.register_default(
    metrics.counter(
        'by_path_counter', 'Request count by request paths',
        labels={'path': lambda: request.path}
    )
)


@app.route("/run", methods=["POST"]) # type: ignore
def run():
    """/run route handler
    """
    body = request.get_json()

    assert body is not None

    submission_id = body['submission_id']
    source_file = body['source_code']
    task_id = body['task_id']
    lang = body['language']
    # TODO: change this
    ext = ''
    if lang == "Python":
        ext = "py"
    else:
        ext = "java"

    filename = "Main"


    info(f'Got request with: {submission_id=}')
    info(f'Got request with: {source_file=}')
    info(f'Got request with: {task_id=}')
    info(f'Got request with: {ext=}')

    source_file_decoded = b64decode(source_file).decode("utf-8")

    try:
        runner = Orchestrator(task_id, ext)
        report = runner.run(submission_id, filename, source_file_decoded)
    except RuntimeError as e:
        print(e)
        return 500
    except ValueError as e:
        print(e)
        return 500

    post(f"{JUGGLER}/report", json=report)
    return "Done"
