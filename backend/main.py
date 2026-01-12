from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from supabase_client import supabase


app = FastAPI()

@app.get("/")
def root():
    return {"message":"Server running"}

class TaskCreate(BaseModel):
    title :str

@app.post("/tasks")
def create_task(task:TaskCreate):
    response = supabase.table("tasks").insert({
        "title":task.title
    }).execute()

    return {
        "status":"success",
        "data":response.data
    }

@app.get("/tasks")
def get_tasks():
    response = supabase.table("tasks").select("*").execute()

    return {
        "status":"success",
        "data":response.data
    }