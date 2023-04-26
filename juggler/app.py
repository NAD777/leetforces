from flask import Flask, request, jsonify
from database.db_session import create_session, global_init
from database.all_models import *

app = Flask(__name__)
app.config.from_object(__name__)
global_init("backbase")


@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


@app.route("/submit", methods=["POST"])
def submit():
    print(request.form)
    print(request.files.get("source_file"))
    return "Done"


@app.route("/list", methods=["GET"])
def get_list():
    chat_id = request.args.get("chat_id")
    session = create_session()
    tasks = session.query(Task).all()
    tasks_dict = {
        "list": [{"task_id": task.task_id, "task_name": task.task_name} for task in tasks],
        "chat_id": chat_id
    }
    return jsonify(tasks_dict)


@app.route("/get_task", methods=["GET"])
def get_task():
    chat_id = request.args.get("chat_id")
    task_id = request.args.get("task_id")
    session = create_session()
    task = session.query(Task).filter(Task.task_id == task_id).one()
    file_content = None
    with open(f"test_files/{task.task_name}", 'rb') as file:
        file_content = str(file.read())
    task_dict = {
        "chat_id": chat_id,
        "task_id": task_id,
        "task_name": task.task_name,
        "task_file": file_content
    }
    return jsonify(task_dict)


@app.route("/register", methods=["POST", "DELETE"])
def register():
    chat_id = request.args.get("chat_id")
    session = create_session()
    print(request.method)
    if request.method == "POST":
        chat = Chat(chat_id=chat_id)
        session.add(chat)
        session.commit()
    elif request.method == "DELETE":
        chat = session.query(Chat).filter(Chat.chat_id == chat_id).first()
        session.delete(chat)
        session.commit()
    return "Done"


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000)
