import sqlalchemy as sa
import sqlalchemy.orm as orm
from sqlalchemy.orm import Session
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import registry

import sqlalchemy.ext.declarative as dec


class SqlAlchemyBase(DeclarativeBase):
    pass


import os

PASSWORD = "user_1"
PASSWORD = os.environ['PASSWORD']
__factory = None


def global_init(db_file):
    global __factory

    if __factory:
        return

    if not db_file or not db_file.strip():
        raise Exception("Need to enter name of db")

    # conn_str = f'sqlite:///{db_file.strip()}?check_same_thread=False'
    # conn_str = f'postgresql://postgres:{PASSWORD}@postgres:5432/{db_file}'
    conn_str = f'postgresql://user_1:{PASSWORD}@localhost:5432/{db_file}'
    print(f"Conn base {conn_str}")

    from time import sleep
    # sleep(2)
    engine = sa.create_engine(conn_str, echo=False)
    __factory = orm.sessionmaker(bind=engine)

    SqlAlchemyBase.metadata.create_all(engine)


def create_session() -> Session:
    global __factory
    return __factory()
