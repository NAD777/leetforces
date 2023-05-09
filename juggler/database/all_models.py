import sqlalchemy
from .db_session import SqlAlchemyBase


class Chat(SqlAlchemyBase):
    __tablename__ = 'Chat'

    id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True, autoincrement=True)
    chat_id = sqlalchemy.Column(sqlalchemy.BIGINT, unique=False, nullable=False)

    def __repr__(self):
        return '<Chat {} {}>'.format(self.id, self.chat_id)


class Submission(SqlAlchemyBase):
    __tablename__ = 'Submission'

    submission_id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True, autoincrement=True)
    task_id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True, autoincrement=True)
    chat_id = sqlalchemy.Column(sqlalchemy.BIGINT, unique=False, nullable=False)

    def __repr__(self):
        return '<Submission {} {}>'.format(self.submission_id, self.chat_id)


class Task(SqlAlchemyBase):
    __tablename__ = 'Task'

    task_id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True, autoincrement=True)
    task_name = sqlalchemy.Column(sqlalchemy.String, unique=False, nullable=False)
    task_file = sqlalchemy.Column(sqlalchemy.String, unique=False, nullable=False)
    task_filename = sqlalchemy.Column(sqlalchemy.String, unique=False, nullable=False)
    master_filename = sqlalchemy.Column(sqlalchemy.String, unique=False, nullable=False)
    master_file = sqlalchemy.Column(sqlalchemy.String, unique=False, nullable=False)
    amount_test = sqlalchemy.Column(sqlalchemy.Integer, unique=False, nullable=False)
    memory_limit = sqlalchemy.Column(sqlalchemy.Integer, unique=False, nullable=False)  # mg
    time_limit = sqlalchemy.Column(sqlalchemy.Float, unique=False, nullable=False)  # s
    author_id = sqlalchemy.Column(sqlalchemy.BIGINT, unique=False, nullable=False)

    def __repr__(self):
        return '<Task {} {}>'.format(self.task_id, self.task_name)
