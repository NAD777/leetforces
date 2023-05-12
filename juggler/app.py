from flask import Flask, request, jsonify
from database.db_session import create_session, global_init
from database.all_models import Submission, Task, Chat
from sqlalchemy.exc import NoResultFound, DataError
from sqlalchemy.orm.exc import UnmappedInstanceError
import requests
from threading import Thread
from os import environ
from prometheus_flask_exporter import PrometheusMetrics

app = Flask(__name__)
metrics = PrometheusMetrics(app, group_by='endpoint')
app.config.from_object(__name__)
global_init("backbase")
PERMITTED_EXTENSIONS = ['py', 'java']
ORCHESTRATOR_URL = environ['ORCHESTRATOR']
BOT_URL = environ['BOT']

#common_counter = metrics.counter(
#    'by_endpoint_counter', 'Request count by endpoints',
#    labels={'endpoint': lambda: request.endpoint}
#)

metrics.register_default(
    metrics.counter(
        'by_path_counter', 'Request count by request paths',
        labels={'path': lambda: request.path}
    )
)


# BOT_URL = "http://localhost:8080"

@app.route("/")
#@common_counter
def hello_world():
    return "<p>Hello, World!</p>"


@app.route("/submit", methods=["POST"])
#@common_counter
def submit():
    json_payload = request.json
    assert json_payload is not None
    chat_id = request.args.get("chat_id")
    filename = json_payload["name"]
    task_no = json_payload["task_no"]
    file = json_payload["source_file"]

    extension = filename.split('.')[-1]

    session = create_session()
    submission = Submission(chat_id=chat_id, task_id=task_no)
    session.add(submission)
    session.commit()

    submission_id = submission.submission_id

    if extension not in PERMITTED_EXTENSIONS:
        return jsonify({"status": "Wrong file extension", "code": 1, "submission_id": submission_id}), 415

    data = {
        "submission_id": submission_id,
        "task_no": task_no,
        "source_file": file,
        "extension": extension,
        "file_name": filename
    }

    Thread(target=lambda: requests.post(
        f"{ORCHESTRATOR_URL}/run", json=data)).start()
    # TODO: handle rEsponse from ORCHESTRATOR

    return jsonify({"status": "File submitted", "code": 0, "submission_id": submission_id}), 200


@app.route('/report', methods=["POST"])
#@common_counter
def report():
    json_payload = request.json
    assert json_payload is not None
    status = json_payload["status"]
    test_num = json_payload["test_num"]
    run_time = json_payload["run_time"]
    memory_used = json_payload["memory_used"]
    submit_id = json_payload["submit_id"]

    session = create_session()
    submission = None
    submission_task = None
    try:
        submission = session.query(Submission).filter(
            Submission.submission_id == submit_id).one()
        submission_task = session.query(Task).filter(
            Task.task_id == submission.task_id).one()
    except NoResultFound:
        return jsonify({"status": "No such submission", "code": 1}), 200

    data = {
        "status": status,
        "test_num": test_num,
        "run_time": run_time,
        "memory_used": memory_used,
        "submit_id": submit_id,
        "chat_id": submission.chat_id,
        "task_name": submission_task.task_name
    }

    requests.post(f"{BOT_URL}/update", json=data)
    return jsonify({"status": "Submitted to bot", "code": 0}), 200


@app.route("/list", methods=["GET"])
#@common_counter
def get_list():
    # chat_id = request.args.get("chat_id")
    session = create_session()
    tasks = session.query(Task).all()
    print(tasks)
    tasks_dict = {
        "list": [{"task_id": task.task_id, "task_name": task.task_name} for task in tasks],
        # "chat_id": chat_id
    }
    print(tasks_dict)
    return jsonify(tasks_dict)


@app.route("/get_task", methods=["GET"])
#@common_counter
def get_task():
    # chat_id = request.args.get("chat_id")
    task_id = request.args.get("task_id")
    session = create_session()
    task = None
    try:
        task = session.query(Task).filter(Task.task_id == task_id).one()
    except (NoResultFound, DataError):
        return [], 404
    # file_content = None
    # with open(f"{task.task_file}", 'rb') as file:
    #     file_content = str(base64.b64encode(file.read()))[2:-1]
    task_dict = {
        "task_id": task_id,
        "task_name": task.task_name,
        "filename": task.task_filename,
        "task_file": task.task_file
    }
    return jsonify(task_dict)


@app.route("/chat", methods=["POST", "DELETE"])
#@common_counter
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


@app.route("/get_task_info")
#@common_counter
def get_task_info():
    task_id = request.args.get("task_id")
    session = create_session()
    task = None
    try:
        task = session.query(Task).filter(Task.task_id == task_id).one()
    except NoResultFound:
        return jsonify({'status': "Task does not exist", 'code': 1}), 404
    response = {
        "master_filename": task.master_filename,
        "master_file": task.master_file,
        "amount_test": task.amount_test,
        "memory_limit": task.memory_limit,
        "time_limit": task.time_limit,
        'code': 0
    }
    return jsonify(response), 200


@app.route("/add_task", methods=["POST"])
#@common_counter
def add_task():
    author_id = request.args.get("chat_id")

    json_payload = request.json
    assert json_payload is not None
    task = Task(
        task_name=json_payload['task_name'],
        task_file=json_payload['task_file'],
        task_filename=json_payload['task_filename'],
        master_filename=json_payload['master_filename'],
        master_file=json_payload['master_file'],
        amount_test=json_payload['amount_test'],
        memory_limit=json_payload['memory_limit'],
        time_limit=json_payload['time_limit'],
        author_id=author_id
    )
    try:
        session = create_session()
        session.add(task)
        session.commit()
        response = {
            'status': "Fine",
            'code': 0
        }
        return jsonify(response)
    except BaseException:
        response = {
            'status': "Error",
            'code': 1
        }
        return jsonify(response)


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000)
