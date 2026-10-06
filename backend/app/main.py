from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session

from . import crud
from .schemas import TaskCreate
from .database import get_db

app = FastAPI()


@app.get("/")
def root():
    return {"message": "Taskflow backend is running"}


@app.get("/tasks")
def get_tasks(db: Session = Depends(get_db)):
    return crud.get_tasks(db)


@app.post("/tasks")
def create_task(
    task: TaskCreate,
    db: Session = Depends(get_db)
):
    return crud.create_task(db, task)

