# import sqlalchemy
from .db_session import SqlAlchemyBase
from sqlalchemy.orm import relationship
from sqlalchemy import Column, ForeignKey, UniqueConstraint
from sqlalchemy import String, Boolean, Integer, Float, DateTime
from datetime import datetime


class User(SqlAlchemyBase):
    __tablename__ = 'User'

    id = Column(Integer, primary_key=True, autoincrement=True)
    login = Column(String, unique=True, nullable=False)
    is_admin = Column(Boolean, nullable=False, unique=False)
    email = Column(String, unique=True, nullable=False)
    password = Column(String, unique=False, nullable=False)
    chat_id = Column(String, unique=True, nullable=True)

    __table_args__ = (
        UniqueConstraint('login', name='unique_login'),
        UniqueConstraint('email', name='unique_email'),
        UniqueConstraint('chat_id', name='unique_telegram_chat_id')
    )

    def __repr__(self):
        return '<User {} {}>'.format(self.id, self.login, self.is_admin, self.email, self.password, self.chat_id)


class Task(SqlAlchemyBase):
    __tablename__ = 'Task'

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, unique=False, nullable=False)
    description = Column(String, unique=False, nullable=False)
    memory_limit = Column(Integer, unique=False, nullable=False)
    time_limit = Column(Float, unique=False, nullable=False)
    amount_of_tests = Column(Integer, unique=False, nullable=False)
    master_filename = Column(String, unique=False, nullable=False)
    master_solution = Column(String, unique=False, nullable=False)
    author_id = Column(Integer, ForeignKey("User.id"))

    def __repr__(self):
        return '<Task {} {}>'.format(self.id, self.name)


class Submission(SqlAlchemyBase):
    __tablename__ = "Submission"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey('User.id'))
    task_id = Column(Integer, ForeignKey("Task.id"))
    source_code = Column(String, unique=False, nullable=False)
    language = Column(String, unique=False, nullable=False)
    status = Column(String, unique=False, nullable=True)
    test_number = Column(Integer, unique=False, nullable=True)
    submission_time = Column(DateTime, unique=False, nullable=False, default=datetime.now)
    memory = Column(Integer, unique=False, nullable=True)
    time = Column(Float, unique=False, nullable=True)

    def __repr__(self):
        return '<Submission {} {}>'.format(self.id, self.user_id, self.task_id, self.status)


class Contest(SqlAlchemyBase):
    __tablename__ = "Contest"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, unique=False, nullable=False)
    description = Column(String, unique=False, nullable=False)
    author_id = Column(Integer, ForeignKey("User.id"))


class ContestTask(SqlAlchemyBase):
    __tablename__ = "ContestTask"

    id = Column(Integer, primary_key=True, autoincrement=True)
    contest_id = Column(Integer, ForeignKey('Contest.id'))
    task_id = Column(Integer, ForeignKey("Task.id"))

    def __repr__(self):
        return 'ContestTask id: {}, contest_id: {}, task_id: {}'.format(self.id, self.contest_id, self.task_id)
