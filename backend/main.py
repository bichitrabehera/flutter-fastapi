from fastapi import Depends, FastAPI, HTTPException
from auth import get_user_id
from pydantic import BaseModel
from supabase_client import supabase
from postgrest.exceptions import APIError

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Server running"}

class TaskCreate(BaseModel):
    title: str
    description: str | None = None

@app.post("/tasks")
def create_task(task: TaskCreate, user_id: str = Depends(get_user_id)):
    try:
        response = supabase.table("tasks").insert({
            "title": task.title,
            "description": task.description,
            "user_id": user_id
        }).execute()
    except APIError as e:
        raise HTTPException(status_code=403, detail=e.json())

    return {"status": "success", "data": response.data}

@app.get("/tasks")
def get_tasks(user_id: str = Depends(get_user_id)):
    response = supabase.table("tasks") \
        .select("*") \
        .eq("user_id", user_id) \
        .execute()

    return {"status": "success", "data": response.data}

class TaskUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    completed: bool | None = None

@app.put("/tasks/{task_id}")
def update_tasks(
    task_id: str,
    task: TaskUpdate,
    user_id: str = Depends(get_user_id)
):
    updated_data = task.dict(exclude_unset=True)

    if not updated_data:
        return {"status": "error", "message": "No fields to update"}

    response = supabase.table("tasks") \
        .update(updated_data) \
        .eq("id", task_id) \
        .eq("user_id", user_id) \
        .execute()

    return {"status": "success", "data": response.data}

@app.delete("/tasks/{task_id}")
def delete_tasks(task_id: str, user_id: str = Depends(get_user_id)):
    response = supabase.table("tasks") \
        .delete() \
        .eq("id", task_id) \
        .eq("user_id", user_id) \
        .execute()

    return {"status": "success", "data": response.data}
