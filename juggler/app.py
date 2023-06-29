import json

from flask import Flask, request, jsonify
from database.db_session import create_session, global_init
from database.all_models import User, Task, Submission, ContestTask, Contest, Role, Tag, ContestTag, UserTag
from sqlalchemy.exc import NoResultFound, DataError
from sqlalchemy.orm.exc import UnmappedInstanceError
from sqlalchemy.exc import IntegrityError
from sqlalchemy import update as sqlalchemy_update
from sqlalchemy import delete as sqlalchemy_delete
import requests
from threading import Thread
from os import environ
from prometheus_flask_exporter import PrometheusMetrics
from functools import wraps
import jwt
import os

from typing import List, Dict

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


def token_required(admin_required=False, super_admin_required=False):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
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
                current_user = session.query(User).filter(User.id == data['user_id']).first()

                if not current_user:
                    return {
                               "message": "Invalid Authentication token!",
                               "data": None,
                               "error": "Unauthorized"
                           }, 401
                if admin_required and not current_user.role in [Role.admin, Role.superAdmin]:
                    return {
                               "message": "Access denied. Admin privileges required.",
                               "data": None,
                               "error": "Forbidden"
                           }, 403
                if super_admin_required and current_user.role == Role.superAdmin:
                    return {
                               "message": "Access denied. Super Admin privileges required.",
                               "data": None,
                               "error": "Forbidden"
                           }, 403
            except Exception as e:
                return {
                           "message": "Something went wrong",
                           "data": None,
                           "error": str(e)
                       }, 500
            return f(current_user, *args, **kwargs)

        return decorated_function

    return decorator


@app.route('/')
@token_required()
def check_token_works(current_user):
    return jsonify(current_user.id)


@app.route('/check_privileges')
@token_required()
def check_privileges(current_user):
    return str(current_user.role)


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


def get_user_tags(user_id) -> List[Dict]:
    session = create_session()
    user = session.query(User).filter(User.id == user_id).first()
    return [tag.to_dict() for tag in user.tags]


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
                           "data": token,
                           'login': user.login,
                           'role': str(user.role.name),
                           'email': user.email,
                           'chat_id': user.chat_id,
                           'tags': get_user_tags(user_id=user.id)
                       }, 200
            except Exception as e:
                return {
                           "error": "Something went wrong!",
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
            password=password
        )
        new_user.tags.append(session.query(Tag).filter(Tag.name == "All").first())
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


@app.route('/current_user_info', methods=['GET'])
@token_required()
def current_user_info(current_user):
    return jsonify({
        'login': current_user.login,
        'role': str(current_user.role),
        'email': current_user.email,
        'chat_id': current_user.chat_id
    }), 200


@app.route('/create_task', methods=["POST"])
@token_required(admin_required=True)
def create_task(current_user):
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


@app.route('/delete_task/<int:task_id>', methods=["DELETE"])
@token_required(admin_required=True)
def delete_task(current_user, task_id):
    # json_payload = request.json
    # if 'task_id' not in json_payload:
    #     return jsonify({
    #         'status': 'Error',
    #         'message': f'No task_id was provided'
    #     })
    # task_id = json_payload['task_id']
    session = create_session()

    task = session.query(Task).filter(Task.id == task_id).first()
    if task is None:
        return jsonify({
            'status': 'Error',
            'message': f'Task with id {task_id} does not exists'
        }), 404

    for relation in session.query(ContestTask).filter(ContestTask.task_id == task.id):
        session.delete(relation)
    session.delete(task)
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


@app.route('/get_task/<int:task_id>', methods=['GET'])
def get_task(task_id):
    # json_payload = dict(request.json)
    # if check := require_keys(json_payload.keys(), ['task_id']):
    #     return jsonify({
    #         'status': 'Error',
    #         'message': f'No {check} was provided'
    #     })
    session = create_session()
    # task_id = json_payload['task_id']
    task = session.query(Task).filter(Task.id == task_id)
    if task.count == 0:
        return jsonify({
            'status': 'Error',
            'message': f'There is no such task with id {task_id}'
        }), 404
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


@app.route("/get_task_info/<int:task_id>")
def get_task_info(task_id):
    # if check := require_keys(request.args.keys(), ['task_id']):
    #     return jsonify({
    #         'status': 'Error',
    #         'message': f'No {check} was provided'
    #     }), 404
    # task_id = request.args.get("task_id")
    session = create_session()
    task = session.query(Task).filter(Task.id == task_id)
    if task.count == 0:
        return jsonify({
            'status': 'Error',
            'message': f'There is no such task with id {task_id}'
        }), 404
    task = task.first()
    return jsonify({
        'status': "Accepted",
        "master_filename": task.master_filename,
        "master_file": task.master_solution,
        "amount_test": task.amount_of_tests,
        "memory_limit": task.memory_limit,
        "time_limit": task.time_limit
    }), 200


@app.route('/submit', methods=["POST"])
@token_required()
def submit(current_user):
    json_payload = dict(request.json)
    if check := require_keys(json_payload, ['task_id', 'source_code', 'language']):
        return jsonify({
            'status': 'Error',
            'message': f'No {check} was provided'
        }), 400
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
        }), 403
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
@token_required(admin_required=True)
def edit_task(current_user):
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


@app.route('/add_contest', methods=["POST"])
@token_required(admin_required=True)
def add_contest(current_user):
    json_payload = dict(request.json)
    if not_given_key := require_keys(json_payload.keys(), ['contest_name', 'description']):
        return jsonify({
            'status': 'Error',
            'message': f'No {not_given_key} was provided'
        }), 400

    session = create_session()
    name = json_payload['contest_name']
    description = json_payload['description']
    is_closed = False
    if 'is_closed' in json_payload:
        is_closed = json_payload['is_closed']
    added_task = []

    new_contest = Contest(
        name=name,
        description=description,
        author_id=current_user.id,
        is_closed=is_closed
    )
    if 'tags' in json_payload:
        tags = json_payload['tags']
        for tag_id in tags:
            tag = session.query(Tag).filter(Tag.id == tag_id).first()
            if tag is None:
                continue
            new_contest.tags.append(tag)
    session.add(new_contest)
    session.commit()

    if 'tasks_ids' in json_payload:
        tasks_ids = json_payload['tasks_ids']
        for task_id in tasks_ids:
            task = session.query(Task).filter(Task.id == task_id).first()
            if task is None:
                continue
            added_task.append(task_id)
            new_contest.tasks.append(task)
            session.commit()

    return jsonify({
        'status': 'Accepted',
        'message': f'New contest was added with id {new_contest.id}',
        'added_task': added_task
    })


@app.route('/delete_contest/<int:contest_id>', methods=["DELETE"])
@token_required(admin_required=True)
def delete_contest(current_user, contest_id):
    # json_payload = request.json
    # if 'contest_id' not in json_payload:
    #     return jsonify({
    #         'status': 'Error',
    #         'message': f'No contest_id was provided'
    #     }), 400

    session = create_session()
    # contest_id = json_payload['contest_id']
    contest = session.query(Contest.id == contest_id).first()
    if contest is None:
        return jsonify({
            'status': 'Error',
            'message': f'Contest with id {contest_id} does not exists'
        }), 404
    statement_delete_relations = sqlalchemy_delete(ContestTask).where(ContestTask.contest_id == contest_id)
    session.execute(statement_delete_relations)
    statement_delete_contest = sqlalchemy_delete(Contest).where(Contest.id == contest_id)
    session.execute(statement_delete_contest)
    session.commit()
    return jsonify({
        'status': 'Accepted',
        'message': f'Contest with id {contest_id} was successfully deleted'
    })


@app.route('/list_contests')
def list_contests():
    session = create_session()
    contests = session.query(Contest).all()
    tasks_dict = {
        "contest_list": [{"contest_id": contest.id, "contest_name": contest.name} for contest in contests],
    }
    return jsonify(tasks_dict), 200


def retrieve_contest_task_ids(contest: Contest):
    session = create_session()
    return [relation.task_id for relation in
            session.query(ContestTask).filter(ContestTask.contest_id == contest.id)]


def retrieve_contest_tags(contest: Contest):
    session = create_session()
    return [relation.tag_id for relation in
            session.query(ContestTag).filter(ContestTag.contest_id == contest.id)]


@app.route('/get_contest/<int:contest_id>')
def get_contest(contest_id):
    # json_payload = request.json
    # if 'contest_id' not in json_payload:
    #     return jsonify({
    #         'status': 'Error',
    #         'message': f'No contest_id was provided'
    #     }), 400
    # contest_id = json_payload['contest_id']
    session = create_session()
    contest = session.query(Contest).where(Contest.id == contest_id).first()
    if not contest:
        return jsonify({
            'status': 'Error',
            'message': f'Contest with id {contest_id} does not exists'
        }), 404

    # tasks_ids = retrieve_contest_task_ids(contest)
    return jsonify(contest.to_dict())


@app.route('/edit_contest')
@token_required(admin_required=True)
def edit_contest(current_user):
    json_payload = request.json
    if 'contest_id' not in json_payload:
        return jsonify({
            'status': 'Error',
            'message': f'No contest_id was provided'
        }), 400

    if check := check_for_allowed_keys(json_payload.keys(),
                                       ['contest_id', 'contest_name', 'description',
                                        'tasks_ids', 'author_id', 'is_closed', "tags"]):
        return jsonify({
            'status': 'Error',
            'message': f'{check} is unknown field'
        }), 400
    contest_id = json_payload['contest_id']
    session = create_session()
    contest = session.query(Contest).filter(Contest.id == contest_id).first()
    if not contest:
        return jsonify({
            'status': 'Error',
            'message': f'Contest with id {contest_id} does not exists'
        }), 404

    to_update = {}
    if 'contest_name' in json_payload:
        to_update['name'] = json_payload['contest_name']

    if 'description' in json_payload:
        to_update['description'] = json_payload['description']

    if 'author_id' in json_payload:
        to_update['author_id'] = json_payload['author_id']

    if 'is_closed' in json_payload:
        to_update['is_closed'] = json_payload['is_closed']

    if 'tasks_ids' in json_payload:
        tasks_ids = retrieve_contest_task_ids(contest)
        new_task_ids = json_payload['tasks_ids']

        for task_id in set(tasks_ids) - set(new_task_ids):
            for relation_to_delete in session.query(ContestTask).filter(ContestTask.task_id == task_id):
                session.delete(relation_to_delete)
        session.commit()
        for task_id in set(new_task_ids) - set(tasks_ids):
            relation_to_add = ContestTask(contest_id=contest.id, task_id=task_id)
            session.add(relation_to_add)
        session.commit()

    if 'tags' in json_payload:
        new_tags_ids = json_payload['tags']
        tags_ids = retrieve_contest_tags(contest)
        for tag_id in set(tags_ids) - set(new_tags_ids):
            for relation_to_delete in session.query(ContestTag).filter(ContestTag.tag_id == tag_id):
                session.delete(relation_to_delete)
        session.commit()
        for tag_id in set(new_tags_ids) - set(tags_ids):
            relation_to_add = ContestTag(contest_id=contest.id, tag_id=tag_id)
            session.add(relation_to_add)
        session.commit()

    session.query(Contest).filter(Contest.id == contest_id).update(to_update)
    session.commit()
    return jsonify({
        'status': 'Accepted',
        'message': f'Contest was edited with id {contest.id}'
    })


@app.route('/report', methods=["POST"])
def report():
    json_payload = dict(request.json)
    if not_given_key := require_keys(json_payload.keys(),
                                     ['submission_id', 'runtime', 'memory', 'status', 'test_number']):
        return jsonify({
            'status': 'Error',
            'message': f'No {not_given_key} was provided'
        }), 400
    session = create_session()
    submission_id = json_payload.pop('submission_id')
    submission = session.query(Submission).filter(Submission.id == submission_id).first()
    if not submission:
        return jsonify({
            'status': 'Error',
            'message': f'Contest with id {submission_id} does not exists'
        }), 404
    session.query(Submission).filter(Submission.id == submission_id).update(json_payload)
    session.commit()

    return jsonify({
        "status": "Accepted",
        "message": "Report has been delivered"
    }), 200


@app.route("/add_tag", methods=["POST"])
@token_required(admin_required=True)
def add_tag(current_user):
    json_payload = request.json
    if 'tag_name' not in json_payload:
        return jsonify({
            'status': 'Error',
            'message': f'No tag_name was provided'
        }), 400
    tag_name = json_payload['tag_name']
    session = create_session()
    new_tag = Tag(name=tag_name)
    session.add(new_tag)
    session.commit()
    return jsonify({
        "status": "Accepted",
        "message": f"Tag with name {tag_name} successfully created",
        'tag_id': new_tag.id
    }), 200


@app.route("/delete_tag/<int:tag_id>", methods=["DELETE"])
@token_required(admin_required=True)
def delete_tag(current_user, tag_id):
    session = create_session()
    tag = session.query(Tag).filter(Task.id == tag_id).first()
    if tag is None:
        return jsonify({
            'status': 'Error',
            'message': f'Tag with id {tag_id} does not exists'
        }), 404

    session.delete(tag)
    session.commit()
    return jsonify({
        'status': 'Accepted',
        'message': f'Tag with id {tag_id} was successfully deleted'
    })


@app.route('/add_tag_to_user', methods=['POST'])
@token_required(admin_required=True)
def add_tag_to_user(current_user):
    json_payload = request.json
    if not_given_key := require_keys(json_payload.keys(),
                                     ['user_id', 'tag_id']):
        return jsonify({
            'status': 'Error',
            'message': f'No {not_given_key} was provided'
        }), 400
    user_id = json_payload['user_id']
    session = create_session()
    user = session.query(User).filter(User.id == user_id).first()
    if user is None:
        return jsonify({
            'status': 'Error',
            'message': f'User with id {user_id} does not exists'
        }), 404
    tag_id = json_payload['tag_id']
    tag = session.query(Tag).filter(Tag.id == tag_id).first()
    if tag is None:
        return jsonify({
            'status': 'Error',
            'message': f'Tag with id {tag_id} does not exists'
        }), 404
    user.tags.append(tag)
    session.commit()
    return jsonify({
        "status": "Accepted",
        "message": f"Tag with id {tag_id} successfully added to User with id {user_id}"
    })


def get_list_tags() -> List[Dict]:
    session = create_session()
    return [tag.to_dict() for tag in session.query(Tag).all()]


@app.route("/tags_list", methods=['GET'])
def tags_list():
    return {
        'tags_list': get_list_tags()
    }


@app.route('/contests_by_tag/<int:tag_id>', methods=['GET'])
def contests_by_tag(tag_id):
    session = create_session()
    tag = session.query(Tag).filter(Tag.id == tag_id).first()
    if tag is None:
        return jsonify({
            'status': 'Error',
            'message': f'Tag with id {tag_id} does not exists'
        }), 404

    return jsonify({
        "tag_name": tag.name,
        "contests": [contest.to_dict() for contest in tag.contests]
    })


@app.route('/public_user_info/<int:user_id>', methods=['GET'])
def public_user_info(user_id):
    session = create_session()
    user = session.query(User).filter(User.id == user_id).first()
    if user is None:
        return jsonify({
            'status': 'Error',
            'message': f'User with id {user_id} does not exists'
        }), 404
    return user.public_info()


def retrieve_user_tags(user: User):
    session = create_session()
    return [relation.tag_id for relation in
            session.query(UserTag).filter(UserTag.user_id == user.id)]


@app.route('/edit_user', methods=['POST'])
@token_required()
def edit_user(current_user):
    json_payload = request.json
    if not_given_key := require_keys(json_payload.keys(), ['user_id']):
        return jsonify({
            'status': 'Error',
            'message': f'No {not_given_key} was provided'
        }), 400

    if res := check_for_allowed_keys(json_payload.keys(),
                                     ['user_id', 'login', 'role', 'email',
                                      'password', 'chat_id', 'tags']):
        return jsonify({
            'status': 'Error',
            'message': f'{res} is unknown field'
        }), 400
    user_id = json_payload['user_id']
    session = create_session()
    user = session.query(User).filter(User.id == user_id).first()
    if not user:
        return jsonify({
            'status': 'Error',
            'message': f'User does not exists'
        }), 404

    if current_user.role == Role.user and current_user.id != user_id:
        return jsonify({
            'status': 'Error',
            'message': f'You do not have privileges'
        }), 403

    to_update = {}
    if 'login' in json_payload:
        to_update['login'] = json_payload['login']
    if 'role' in json_payload and current_user.role.value > 1:
        if json_payload['role'] == 'user':
            to_update['role'] = Role.user
        elif json_payload['role'] == 'admin' and current_user.role.value in [2, 3]:
            to_update['role'] = Role.admin
        elif json_payload['role'] == 'superAdmin' and current_user.role == 3:
            to_update['role'] = Role.superAdmin
    if 'email' in json_payload:
        to_update['email'] = json_payload['email']
    if 'password' in json_payload:
        to_update['password'] = json_payload['password']
    if 'chat_id' in json_payload:
        to_update['chat_id'] = json_payload['chat_id']
    if len(to_update) != 0:
        try:
            session = create_session()
            print(to_update)
            session.query(User).filter(User.id == user_id).update(to_update)
            session.commit()
        except IntegrityError as int_error:
            constraint = int_error.args[0].split('\n')[0].split()[-1]
            return jsonify({
                'status': 'Error',
                'message': f'Violates constraint {constraint}'
            }), 400
    session = create_session()
    if 'tags' in json_payload and current_user.role in [Role.admin, Role.superAdmin]:
        new_tags_ids = json_payload['tags']
        tags_ids = retrieve_user_tags(user)
        for tag_id in set(tags_ids) - set(new_tags_ids):
            for relation_to_delete in session.query(UserTag).filter(UserTag.tag_id == tag_id):
                session.delete(relation_to_delete)
        session.commit()
        for tag_id in set(new_tags_ids) - set(tags_ids):
            relation_to_add = UserTag(user_id=user_id, tag_id=tag_id)
            session.add(relation_to_add)
        session.commit()
    print(to_update)
    return jsonify({
        'status': 'Accepted',
        'message': f'User was edited with id {user.id}'
    })


@app.route('/get_submission/<int:task_id>', methods=["GET"])
@token_required()
def get_submission(current_user, task_id):
    session = create_session()
    if session.query(Task).filter(Task.id == task_id).first() is None:
        return jsonify({
            'status': 'Error',
            'message': f'Task does not exists'
        }), 404

    if current_user.role == Role.user:
        return jsonify([
            sub.to_dict() for sub in session.query(Submission).filter(Submission.user_id == current_user.id,
                                                                      Submission.task_id == task_id)
        ]), 200
    else:
        return jsonify([
            sub.to_dict() for sub in session.query(Submission).filter(Submission.task_id == task_id)
        ]), 200


if __name__ == '__main__':
    session = create_session()
    if not session.query(Tag).filter(Tag.name == "All").first():
        session.add(Tag(name="All"))
        session.commit()
    app.run(host="0.0.0.0", port=8000)
