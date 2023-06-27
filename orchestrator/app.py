# route /run for POST requests
# accept
# {
#   submission_id : <sub_id>
#   source_file : file
#   task_no : <task_no>
#   extension : <ext>
#   file_name : <file_name>
# }
#
from flask import Flask, request
from requests import post
from base64 import b64decode
from os import environ
from logging import basicConfig, debug, DEBUG
from prometheus_flask_exporter import PrometheusMetrics

from orchestrator import Orchestrator

JUGGLER = environ["JUGGLER"]

app = Flask(__name__)
app.config.from_object(__name__)

metrics = PrometheusMetrics(app, group_by='endpoint')

metrics.register_default(
    metrics.counter(
        'by_path_counter', 'Request count by request paths',
        labels={'path': lambda: request.path}
    )
)


@app.route("/run", methods=["POST"])
def run():
    """/run route handler
    """
    body = request.get_json()

    assert body is not None

    submission_id = body['submission_id']
    source_file = body['source_file']
    task_id = body['task_no']
    ext = body['extension']
    filename = body['file_name']

    basicConfig(level=DEBUG)
    debug(f'Got request with: {submission_id=}')
    debug(f'Got request with: {source_file=}')
    debug(f'Got request with: {task_id=}')
    debug(f'Got request with: {ext=}')

    source_file_decoded = b64decode(source_file).decode("utf-8")

    try:
        runner = Orchestrator(task_id, ext)
        report = runner.run(submission_id, filename, source_file_decoded)
    except ValueError as e:
        print(e)
        return 500

    post(f"{JUGGLER}/report", json=report)
    return "Done"
