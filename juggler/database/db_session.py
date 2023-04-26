import sqlalchemy as sa
import sqlalchemy.orm as orm
from sqlalchemy.orm import Session
import sqlalchemy.ext.declarative as dec

SqlAlchemyBase = dec.declarative_base()
PASSWORD = "PLACE FOR PASSWORD"


__factory = None


def global_init(db_file):
    global __factory

    if __factory:
        return

    if not db_file or not db_file.strip():
        raise Exception("Need to enter name of db")

    # conn_str = f'sqlite:///{db_file.strip()}?check_same_thread=False'
    conn_str = f'postgresql://postgres:{PASSWORD}@localhost:5432/{db_file}'
    print(f"Conn base {conn_str}")

    engine = sa.create_engine(conn_str, echo=False)
    __factory = orm.sessionmaker(bind=engine)

    from . import all_models

    SqlAlchemyBase.metadata.create_all(engine)


def create_session() -> Session:
    global __factory
    return __factory()
