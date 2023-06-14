# import sqlalchemy
from .db_session import SqlAlchemyBase
from sqlalchemy.orm import relationship
from sqlalchemy import Column, ForeignKey
from sqlalchemy import String, Boolean, Integer, Float, DateTime


class User(SqlAlchemyBase):
    __tablename__ = 'User'

    id = Column(Integer, primary_key=True, autoincrement=True)
    is_admin = Column(Boolean, nullable=False, unique=False)
    email = Column(String, unique=False, nullable=False)
    login = Column(String, unique=False, nullable=False)
    password = Column(String, unique=False, nullable=False)
    chat_id = Column(String, unique=True, nullable=True)

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
    author = relationship("User", back_populates="Task")

    def __repr__(self):
        return '<Task {} {}>'.format(self.id, self.name)


class Submission(SqlAlchemyBase):
    __tablename__ = "Submission"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey('User.id'))
    task_id = Column(Integer, ForeignKey("Task.id"))
    source_code = Column(String, unique=False, nullable=False)
    status = Column(String, unique=False, nullable=False)
    test_number = Column(Integer, unique=False, nullable=False)
    submission_time = Column(DateTime, unique=False, nullable=False)
    memory = Column(Integer, unique=False, nullable=True)
    time = Column(Float, unique=False, nullable=True)

    def __repr__(self):
        return '<Submission {} {}>'.format(self.id, self.user, self.task, self.status)


class Contest(SqlAlchemyBase):
    __tablename__ = "Contest"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, unique=False, nullable=False)
    description = Column(String, unique=False, nullable=False)


class ContestTask(SqlAlchemyBase):
    __tablename__ = "ContestTask"

    id = Column(Integer, primary_key=True, autoincrement=True)
    contest_id = Column(Integer, ForeignKey('Contest.id'))
    task_id = Column(Integer, ForeignKey("Task.id"))
