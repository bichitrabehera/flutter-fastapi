import requests
import json
from jose import jwt
import time

BASE_URL = "http://localhost:8000"

# Create a mock JWT token for testing (since verify_signature is False)
def create_test_token(user_id: str = "test-user-123"):
    payload = {
        "sub": user_id,
        "iat": int(time.time()),
        "exp": int(time.time()) + 3600
    }
    # Since verify_signature is False, we can use any secret
    token = jwt.encode(payload, "test-secret", algorithm="HS256")
    return token

def test_root():
    print("Testing GET /")
    response = requests.get(f"{BASE_URL}/")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    print()

def test_create_task(token):
    print("Testing POST /tasks")
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    data = {
        "title": "Test Task",
        "description": "This is a test task"
    }
    response = requests.post(f"{BASE_URL}/tasks", json=data, headers=headers)
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print()
    return response.json().get("data", [{}])[0].get("id") if response.status_code == 200 else None

def test_get_tasks(token):
    print("Testing GET /tasks")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/tasks", headers=headers)
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print()

def test_update_task(token, task_id):
    if not task_id:
        print("Skipping UPDATE test - no task ID available")
        return
    print(f"Testing PUT /tasks/{task_id}")
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    data = {
        "title": "Updated Test Task",
        "completed": True
    }
    response = requests.put(f"{BASE_URL}/tasks/{task_id}", json=data, headers=headers)
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print()

def test_delete_task(token, task_id):
    if not task_id:
        print("Skipping DELETE test - no task ID available")
        return
    print(f"Testing DELETE /tasks/{task_id}")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.delete(f"{BASE_URL}/tasks/{task_id}", headers=headers)
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print()

def test_invalid_auth():
    print("Testing GET /tasks with invalid auth")
    headers = {"Authorization": "Bearer invalid-token"}
    response = requests.get(f"{BASE_URL}/tasks", headers=headers)
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json() if response.status_code != 200 else response.text}")
    print()

if __name__ == "__main__":
    print("=" * 50)
    print("Testing FastAPI Endpoints")
    print("=" * 50)
    print()
    
    # Wait a moment for server to be ready
    time.sleep(2)
    
    # Test root endpoint (no auth required)
    try:
        test_root()
    except Exception as e:
        print(f"Error testing root: {e}")
        print("Make sure the server is running on http://localhost:8000")
        exit(1)
    
    # Create test token
    test_token = create_test_token()
    print(f"Using test token: {test_token[:50]}...")
    print()
    
    # Test authenticated endpoints
    try:
        task_id = test_create_task(test_token)
        test_get_tasks(test_token)
        test_update_task(test_token, task_id)
        test_delete_task(test_token, task_id)
        test_invalid_auth()
    except Exception as e:
        print(f"Error testing endpoints: {e}")
        import traceback
        traceback.print_exc()
