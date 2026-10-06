from sqlalchemy.orm import Session

from . import models
from .schemas import TaskCreate


def get_tasks(db: Session):

    return db.query(models.Task).all()


def create_task(
    db: Session,
    task: TaskCreate
):

    new_task = models.Task(
        title=task.title,
        status=task.status
    )

    db.add(new_task)
    db.commit()
    db.refresh(new_task)

    return new_task
