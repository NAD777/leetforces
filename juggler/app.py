from flask import Flask, request, jsonify
from database.db_session import create_session, global_init
from database.all_models import *
from sqlalchemy.exc import NoResultFound
from sqlalchemy.orm.exc import UnmappedInstanceError
import base64
import requests

app = Flask(__name__)
app.config.from_object(__name__)
global_init("backbase")
PERMITTED_EXTENSIONS = ['py', 'java']
ORCHESTRATOR_URL = "http://orchestrator:5000"
BOT_URL = "http://bot:5000"


@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


@app.route("/submit", methods=["POST"])
def submit():
    json_payload = request.json
    chat_id = request.args.get("chat_id")
    filename = json_payload["name"]
    task_no = json_payload["task_no"]
    file = json_payload["source_file"]

    extension = filename.split('.')[-1]
    if extension not in PERMITTED_EXTENSIONS:
        return jsonify({"status": "Wrong file extension", "code": 1}), 415

    session = create_session()
    submission = Submission(chat_id=chat_id)
    session.add(submission)
    session.commit()

    submission_id = submission.submission_id

    data = {
        "submission_id": submission_id,
        "task_no": task_no,
        "source_file": file,
        "extension": extension
    }

    r = requests.post(f"{ORCHESTRATOR_URL}/run", data=data)
    # TODO: handle rEsponse from ORCHESTRATOR

    return jsonify({"status": "File submitted", "code": 0}), 200


@app.route('/report', methods=["POST"])
def report():
    json_payload = request.json
    status = json_payload["status"]
    run_time = json_payload["run_time"]
    memory_used = json_payload["memory_used"]
    submit_id = json_payload["submit_id"]

    session = create_session()
    submission = None
    try:
        submission = session.query(Submission).filter(Submission.submission_id == submit_id).one()
    except NoResultFound:
        return jsonify({"status": "No such submission", "code": 1}), 200

    data = {
        "status": status,
        "run_time": run_time,
        "memory_used": memory_used,
        "submit_id": submit_id,
        "chat_id": submission.chat_id
    }

    r = requests.post(f"{BOT_URL}/updates", data=data)
    return jsonify({"status": "Submitted to bot", "code": 0}), 200


@app.route("/list", methods=["GET"])
def get_list():
    # chat_id = request.args.get("chat_id")
    session = create_session()
    tasks = session.query(Task).all()
    tasks_dict = {
        "list": [{"task_id": task.task_id, "task_name": task.task_name} for task in tasks],
        # "chat_id": chat_id
    }
    return jsonify(tasks_dict)


@app.route("/get_task", methods=["GET"])
def get_task():
    # chat_id = request.args.get("chat_id")
    task_id = request.args.get("task_id")
    session = create_session()
    task = None
    try:
        task = session.query(Task).filter(Task.task_id == task_id).one()
    except NoResultFound:
        return [], 404
    file_content = None
    with open(f"test_files/{task.task_path}", 'rb') as file:
        file_content = str(base64.b64encode(file.read()))[2:-1]
    task_dict = {
        # "chat_id": chat_id,
        "task_id": task_id,
        "task_name": task.task_name,
        "task_file": file_content
    }
    return jsonify(task_dict)


@app.route("/chat", methods=["POST", "DELETE"])
def register():
    chat_id = request.args.get("chat_id")
    session = create_session()
    code = 200
    response = {
        'status': None,
        'code': 0
    }
    try:
        if request.method == "POST":
            if len(session.query(Chat).filter(Chat.chat_id == chat_id).all()) != 0:
                response["status"] = "User already present"
                response['code'] = 1
            else:
                chat = Chat(chat_id=chat_id)
                session.add(chat)
                session.commit()
                response["status"] = "User added"
        elif request.method == "DELETE":
            chat = session.query(Chat).filter(Chat.chat_id == chat_id).first()
            session.delete(chat)
            session.commit()
            response["status"] = "User deleted"
    except (NoResultFound, UnmappedInstanceError):
        response["status"] = "Error occurred"
        code = 404
        response['code'] = 2
    return jsonify(response), code


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000)
