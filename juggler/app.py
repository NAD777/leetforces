from flask import Flask, request, jsonify
from database.db_session import create_session, global_init
from database.all_models import User, Task, Submission, ContestTask, Contest
from sqlalchemy.exc import NoResultFound, DataError
from sqlalchemy.orm.exc import UnmappedInstanceError
from sqlalchemy.exc import IntegrityError
from sqlalchemy import update as sqlalchemy_update
import requests
from threading import Thread
from os import environ
from prometheus_flask_exporter import PrometheusMetrics
from functools import wraps
import jwt
import os

app = Flask(__name__)
metrics = PrometheusMetrics(app, group_by='endpoint')
app.config.from_object(__name__)
global_init("backbase")
PERMITTED_LANGUAGES = ['Python', 'Java']
# ORCHESTRATOR_URL = environ['ORCHESTRATOR']
# BOT_URL = environ['BOT']
SECRET_KEY = os.environ.get('SECRET_KEY') or 'this is a secret'
app.config['SECRET_KEY'] = SECRET_KEY

metrics.register_default(
    metrics.counter(
        'by_path_counter', 'Request count by request paths',
        labels={'path': lambda: request.path}
    )
)


def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if "Authorization" in request.headers:
            token = request.headers["Authorization"]
        if not token:
            return {
                       "message": "Authentication Token is missing!",
                       "data": None,
                       "error": "Unauthorized"
                   }, 401
        try:
            data = jwt.decode(token, app.config["SECRET_KEY"], algorithms=["HS256"])
            session = create_session()
            user = session.query(User).filter(User.id == data['user_id'])

            if user.count() == 0:
                return {
                           "message": "Invalid Authentication token!",
                           "data": None,
                           "error": "Unauthorized"
                       }, 401
            current_user = user.first()
        except Exception as e:
            return {
                       "message": "Something went wrong",
                       "data": None,
                       "error": str(e)
                   }, 500
        return f(current_user, *args, **kwargs)

    return decorated


@app.route('/')
@token_required
def check_token_works(current_user):
    return jsonify(current_user.id)


def validate_login_and_password(login, password):
    session = create_session()
    user = session.query(User).filter(User.login == login)
    if user.count == 0:
        return False
    user = user.first()
    if user.password != password:
        return False
    return True


def require_keys(given_keys, needed_keys):
    for key in needed_keys:
        if key not in given_keys:
            return key
    return None


def check_for_allowed_keys(given_keys, allowed_keys):
    for key in given_keys:
        if key not in allowed_keys:
            return key
    return None


@app.route("/login", methods=["POST"])
def login_endpoint():
    try:
        data = request.json
        if not data:
            return {
                       "message": "Please provide user details",
                       "data": None,
                       "error": "Bad request"
                   }, 400
        # validate input
        is_validated = validate_login_and_password(data.get('login'), data.get('password'))
        if is_validated is not True:
            return dict(message='Invalid data', data=None, error=is_validated), 400
        session = create_session()
        user = session.query(User).filter(User.login == data.get('login')).first()
        if user:
            try:
                token = jwt.encode(
                    {"user_id": user.id},
                    app.config["SECRET_KEY"],
                    algorithm="HS256"
                )
                return {
                           "message": "Successfully fetched auth token",
                           "data": token
                       }, 200
            except Exception as e:
                return {
                           "error": "Something went wrong",
                           "message": str(e)
                       }, 500
        return {
                   "message": "Error fetching auth token!, invalid email or password",
                   "data": None,
                   "error": "Unauthorized"
               }, 404
    except Exception as e:
        return {
                   "message": "Something went wrong!",
                   "error": str(e),
                   "data": None
               }, 500


# BOT_URL = "http://localhost:8080"

@app.route("/register", methods=["POST"])
def register():
    json_payload = request.json
    if 'email' not in json_payload:
        return jsonify({
            'status': 'Error',
            'message': 'No e-mail was provided'
        }), 400
    email = json_payload['email']

    if 'login' not in json_payload:
        return jsonify({
            'status': 'Error',
            'message': 'No login was provided'
        }), 400
    login = json_payload['login']

    if 'password' not in json_payload:
        return jsonify({
            'status': 'Error',
            'message': 'No password was provided'
        }), 400
    password = json_payload['password']

    try:
        session = create_session()
        new_user = User(
            email=email,
            login=login,
            password=password,
            is_admin=False
        )
        session.add(new_user)
        session.commit()
    except IntegrityError as int_error:
        constraint = int_error.args[0].split('\n')[0].split()[-1]
        return jsonify({
            'status': 'Error',
            'message': f'Violates constraint {constraint}'
        }), 400
    return jsonify({
        'status': 'Accepted',
        'message': f'User successfully registered'
    }), 200


@app.route('/create_task', methods=["POST"])
@token_required
def create_task(current_user):
    if not current_user.is_admin:
        return jsonify({
            'status': 'Error',
            'message': 'You are not an admin'
        }), 403
    json_payload = dict(request.json)
    if res := require_keys(json_payload.keys(),
                           ['name', 'description', 'memory_limit', 'time_limit',
                            'amount_of_tests', 'master_filename',
                            'master_solution']):
        return jsonify({
            'status': 'Error',
            'message': f'No {res} was provided'
        }), 400
    session = create_session()
    new_task = Task(
        name=json_payload['name'],
        description=json_payload['description'],
        memory_limit=json_payload['memory_limit'],
        time_limit=json_payload['time_limit'],
        amount_of_tests=json_payload['amount_of_tests'],
        master_filename=json_payload['master_filename'],
        master_solution=json_payload['master_solution'],
        author_id=current_user.id
    )
    session.add(new_task)
    session.commit()

    return jsonify({
        'status': 'Accepted',
        'message': 'New task was added',
        'task_number': new_task.id
    })


@app.route('/delete_task', methods=["POST"])
@token_required
def delete_task(current_user):
    if not current_user.is_admin:
        return jsonify({
            'status': 'Error',
            'message': 'You are not an admin'
        }), 403

    json_payload = request.json

    if 'task_id' not in json_payload:
        return jsonify({
            'status': 'Error',
            'message': f'No task_id was provided'
        })
    task_id = json_payload['task_id']
    session = create_session()

    task = session.query(Task).filter(Task.id == task_id)
    if task.count() == 0:
        return jsonify({
            'status': 'Error',
            'message': f'Task with id {task_id} does not exists'
        })

    session.delete(task.first())
    session.commit()
    return jsonify({
        'status': 'Accepted',
        'message': f'Task with id {task_id} was successfully deleted'
    })


@app.route('/get_task_list', methods=['GET'])
def get_task_list():
    session = create_session()
    tasks = session.query(Task).all()
    tasks_dict = {
        "list": [{"task_id": task.id, "task_name": task.name} for task in tasks],
    }
    return jsonify(tasks_dict), 200


@app.route('/get_task', methods=['GET'])
def get_task():
    json_payload = dict(request.json)
    if check := require_keys(json_payload.keys(), ['task_id']):
        return jsonify({
            'status': 'Error',
            'message': f'No {check} was provided'
        })
    session = create_session()
    task_id = json_payload['task_id']
    task = session.query(Task).filter(Task.id == task_id)
    if task.count == 0:
        return jsonify({
            'status': 'Error',
            'message': f'There is no such task with id {task_id}'
        })
    task = task.first()
    task_author = session.query(User).filter(User.id == task.author_id).first()
    return jsonify({
        'status': "Accepted",
        'task_id': task.id,
        'name': task.name,
        'description': task.description,
        'memory_limit': task.memory_limit,
        'time_limit': task.time_limit,
        'author_name': task_author.login
    })


@app.route("/get_task_info")
def get_task_info():
    if check := require_keys(request.args.keys(), ['task_id']):
        return jsonify({
            'status': 'Error',
            'message': f'No {check} was provided'
        }), 404
    task_id = request.args.get("task_id")
    session = create_session()
    task = session.query(Task).filter(Task.id == task_id)
    if task.count == 0:
        return jsonify({
            'status': 'Error',
            'message': f'There is no such task with id {task_id}'
        })
    task = task.first()
    return jsonify({
        'status': "Accepted",
        "master_filename": task.master_filename,
        "master_file": task.master_solution,
        "amount_test": task.amount_of_tests,
        "memory_limit": task.memory_limit,
        "time_limit": task.time_limit,
        'code': 0
    }), 200


@app.route('/submit', methods=["POST"])
@token_required
def submit(current_user):
    json_payload = dict(request.json)
    if check := require_keys(json_payload, ['task_id', 'source_code', 'language']):
        return jsonify({
            'status': 'Error',
            'message': f'No {check} was provided'
        }), 404
    session = create_session()

    task_id = json_payload['task_id']
    if session.query(Task).filter(Task.id == task_id) is None:
        return jsonify({
            'status': 'Error',
            'message': f'Task with id {task_id} does not exists'
        }), 404
    source_code = json_payload['source_code']
    language = json_payload['language']
    if language not in PERMITTED_LANGUAGES:
        return jsonify({
            'status': 'Error',
            'message': f'Language {task_id} is not permitted only: {", ".join(PERMITTED_LANGUAGES)}'
        }), 404
    submission = Submission(
        user_id=current_user.id,
        task_id=task_id,
        source_code=source_code,
        language=language
    )
    session.add(submission)
    session.commit()

    # TODO: uncomment on merge
    # requests.post(f"{ORCHESTRATOR_URL}/run", json=jsonify({
    #     'submission_id': submission.id,
    #     'task_id': task_id,
    #     'source_code': source_code,
    #     'language': language
    # }))
    return jsonify({
        'status': 'Accepted',
        'message': f'Submitted',
        'submission_id': submission.id
    })


@app.route('/edit_task', methods=["POST"])
@token_required
def edit_task(current_user):
    if not current_user.is_admin:
        return jsonify({
            'status': 'Error',
            'message': 'You are not an admin'
        }), 403
    json_payload = dict(request.json)
    if 'task_id' not in json_payload.keys():
        return jsonify({
            'status': 'Error',
            'message': f'No task_id was provided'
        }), 400
    task_id = json_payload['task_id']
    json_payload.pop('task_id')
    if res := check_for_allowed_keys(json_payload.keys(),
                                     ['name', 'description', 'memory_limit', 'time_limit',
                                      'amount_of_tests', 'master_filename',
                                      'master_solution']):
        return jsonify({
            'status': 'Error',
            'message': f'{res} is unknown field'
        }), 400
    session = create_session()
    session.query(Task).filter(Task.id == task_id).update(json_payload)
    session.commit()

    return jsonify({
        'status': 'Accepted',
        'message': f'Task successfully with id {task_id} edited',
    })


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000)
