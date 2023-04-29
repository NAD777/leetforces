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
    chat_id = sqlalchemy.Column(sqlalchemy.BIGINT, unique=False, nullable=False)

    def __repr__(self):
        return '<Submission {} {}>'.format(self.submission_id, self.chat_id)


class Task(SqlAlchemyBase):
    __tablename__ = 'Task'

    task_id = sqlalchemy.Column(sqlalchemy.Integer, primary_key=True, autoincrement=True)
    task_name = sqlalchemy.Column(sqlalchemy.String, unique=False, nullable=False)
    task_path = sqlalchemy.Column(sqlalchemy.String, unique=False, nullable=False)

    def __repr__(self):
        return '<Task {} {}>'.format(self.task_id, self.task_name)
