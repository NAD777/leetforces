# import sqlalchemy
from .db_session import SqlAlchemyBase
from sqlalchemy.orm import relationship
from sqlalchemy import Column, ForeignKey, UniqueConstraint
from sqlalchemy import String, Boolean, Integer, Float, DateTime, Enum
from datetime import datetime
import enum


class Role(enum.Enum):
    user = 1
    admin = 2
    superAdmin = 3


class User(SqlAlchemyBase):
    __tablename__ = 'User'

    id = Column(Integer, primary_key=True, autoincrement=True)
    login = Column(String, unique=True, nullable=False)
    role = Column(Enum(Role), nullable=False, unique=False, default=Role.user)
    email = Column(String, unique=True, nullable=False)
    password = Column(String, unique=False, nullable=False)
    chat_id = Column(String, unique=True, nullable=True)
    tags = relationship('Tag', secondary='UserTag', back_populates='users')

    __table_args__ = (
        UniqueConstraint('login', name='unique_login'),
        UniqueConstraint('email', name='unique_email'),
        UniqueConstraint('chat_id', name='unique_telegram_chat_id')
    )

    def __repr__(self):
        return '<User {} {}>'.format(self.id, self.login, self.role, self.email, self.password, self.chat_id)

    def public_info(self):
        return {
            'login': self.login,
            'role': str(self.role.name),
            "tags": [tag.to_dict() for tag in self.tags]
        }


class Tag(SqlAlchemyBase):
    __tablename__ = "Tag"
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, unique=True, nullable=False)
    users = relationship('User', secondary='UserTag', back_populates='tags')
    contests = relationship('Contest', secondary='ContestTag', back_populates='tags')

    def __repr__(self):
        return 'Tag id: {}, name: {}'.format(self.id, self.name)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name
        }


class UserTag(SqlAlchemyBase):
    __tablename__ = 'UserTag'

    id = Column(Integer, primary_key=True, autoincrement=True)
    tag_id = Column(Integer, ForeignKey('Tag.id'))
    user_id = Column(Integer, ForeignKey('User.id'))


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
    contests = relationship('Contest', secondary='ContestTask', back_populates='tasks')

    def __repr__(self):
        return '<Task {} {}>'.format(self.id, self.name)

    def short_description(self):
        return {
            'task_id': self.id,
            'name': self.name,
            'memory_limit': self.memory_limit,
            'time_limit': self.time_limit,
            'author_id': self.author_id
        }


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
    runtime = Column(Float, unique=False, nullable=True)

    def __repr__(self):
        return '<Submission {} {}>'.format(self.id, self.user_id, self.task_id, self.status)


class Contest(SqlAlchemyBase):
    __tablename__ = "Contest"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String, unique=False, nullable=False)
    description = Column(String, unique=False, nullable=False)
    author_id = Column(Integer, ForeignKey("User.id"))
    is_closed = Column(Boolean, unique=False, nullable=False, default=True)
    tags = relationship('Tag', secondary='ContestTag', back_populates='contests')
    tasks = relationship('Task', secondary='ContestTask', back_populates='contests')

    def to_dict(self):
        return {
            "contest_id": self.id,
            "name": self.name,
            "description": self.description,
            "author_id": self.author_id,
            "tasks_ids": [task.short_description() for task in self.tasks],
            "is_closed": self.is_closed
        }


class ContestTag(SqlAlchemyBase):
    __tablename__ = "ContestTag"

    id = Column(Integer, primary_key=True, autoincrement=True)
    tag_id = Column(Integer, ForeignKey('Tag.id'))
    contest_id = Column(Integer, ForeignKey('Contest.id'))

    def __repr__(self):
        return 'ContestTask id: {}, contest_id: {}, task_id: {}'.format(self.id, self.contest_id, self.task_id)


class ContestTask(SqlAlchemyBase):
    __tablename__ = "ContestTask"

    id = Column(Integer, primary_key=True, autoincrement=True)
    contest_id = Column(Integer, ForeignKey('Contest.id'))
    task_id = Column(Integer, ForeignKey("Task.id"))
