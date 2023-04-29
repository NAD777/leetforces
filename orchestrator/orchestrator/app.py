# route /run for POST requests
# accept
# {
#   submission_id : <sub_id>
#   source_file : file
#   task_no : <task_no>
#   extension : <ext>
# }
#
from flask import Flask, request
import logging
import os
import json

from test_data_generator import DataGenerator

app = Flask(__name__)
app.config.from_object(__name__)

@app.route("/run", methods=["POST"])
def run():
    body = request.get_json()
    
    assert body is not None
    
    submission_id = body['submission_id']
    source_file = body['source_file']
    task_id = body['task_id']
    ext = body['extension']

    # logging.basicConfig(level=logging.DEBUG)
    print(f'Got request with: {submission_id=}')
    print(f'Got request with: {source_file=}')
    print(f'Got request with: {task_id=}')
    print(f'Got request with: {ext=}')

    with open(f"{submission_id}.{ext}", 'w') as f:
        f.write(str(source_file))

    gen = DataGenerator()
    gen.generate_data(task_id)

    return "Done"
