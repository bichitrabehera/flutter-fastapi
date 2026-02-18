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
    completed : bool = False

@app.post("/tasks")
def create_task(task: TaskCreate, user_id: str = Depends(get_user_id)):
    try:
        response = supabase.table("tasks").insert({
            "title": task.title,
            "description": task.description,
            "user_id": user_id,
            "completed" : task.completed
        }).execute()

    except APIError as e:
        raise HTTPException(status_code=403, detail=e.json())

    return {"status": "success", "data": response.data}













@app.get("/tasks")
def get_tasks(
    user_id: str = Depends(get_user_id),
    completed :bool = False,
    sort : str = "created_at"
    ):

    response = supabase.table("tasks") \
        .select("*") \
        .eq("user_id", user_id) \

    response = response.order(sort,desc=True)

    response.execute()

    return {"status": "success", "data": response.data}

















@app.get("/tasks/{task_id}")
def get_tasks(task_id : str , user_id : str = Depends(get_user_id)):

    response = supabase.table("tasks") \
        .select("*") \
        .eq("id", user_id) \
        .eq("task_id",task_id) \
        .execute()

    if not response.data:
        raise HTTPException(status_code=404,detail="Task not found")    

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

    if not response.data:
        raise HTTPException(status_code=404, detail="Task not found")    

    return {"status": "success", "data": response.data}





@app.patch("/tasks/{task_id}/toggle")
def toggle_task(task_id: str, user_id: str = Depends(get_user_id)):
    # 1) fetch current completed value
    task_response = (
        supabase.table("tasks")
        .select("completed")
        .eq("id", task_id)
        .eq("user_id", user_id)
        .execute()
    )

    if not task_response.data:
        raise HTTPException(status_code=404, detail="Task not found")

    current_value = task_response.data[0]["completed"]
    new_value = not current_value

    # 2) update
    response = (
        supabase.table("tasks")
        .update({"completed": new_value})
        .eq("id", task_id)
        .eq("user_id", user_id)
        .execute()
    )

    return {"status": "success", "data": response.data[0]}






@app.delete("/tasks/{task_id}")
def delete_tasks(task_id: str, user_id: str = Depends(get_user_id)):
    response = supabase.table("tasks") \
        .delete() \
        .eq("id", task_id) \
        .eq("user_id", user_id) \
        .execute()

    return {"status": "success", "data": response.data}
