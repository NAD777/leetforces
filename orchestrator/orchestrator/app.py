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
from test_runner import TestRunner

app = Flask(__name__)
app.config.from_object(__name__)

@app.route("/run", methods=["POST"])
def run():
    body = request.get_json()
    
    assert body is not None
    
    submission_id = body['submission_id']
    source_file = body['source_file']
    task_id = body['task_no']
    ext = body['extension']
    filename = body['file_name']

    # logging.basicConfig(level=logging.DEBUG)
    print(f'Got request with: {submission_id=}')
    print(f'Got request with: {source_file=}')
    print(f'Got request with: {task_id=}')
    print(f'Got request with: {ext=}')

    with open(f"{submission_id}.{ext}", 'w') as f:
        f.write(str(source_file))

    runner = TestRunner(task_id, submission_id, ext)
    report = runner.run(filename, source_file)
    # TODO: if report["status"] == "Internal error"
    post("http://juggler:5001/report", json=report)
    return "Done"
