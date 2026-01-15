from fastapi import Depends, HTTPException
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from supabase_client import supabase

security = HTTPBearer()


def _extract_user_id(user_response) -> str | None:
    if user_response is None:
        return None

    if hasattr(user_response, "user") and getattr(user_response, "user"):
        user_obj = getattr(user_response, "user")
        if hasattr(user_obj, "id"):
            return user_obj.id

    if isinstance(user_response, dict):
        user_dict = user_response.get("user")
        if isinstance(user_dict, dict):
            user_id = user_dict.get("id")
            if isinstance(user_id, str):
                return user_id

    if hasattr(user_response, "dict"):
        try:
            data = user_response.dict()
            user_dict = data.get("user")
            if isinstance(user_dict, dict):
                user_id = user_dict.get("id")
                if isinstance(user_id, str):
                    return user_id
        except Exception:
            pass

    return None


def get_user_id(
    credentials: HTTPAuthorizationCredentials = Depends(security),
):
    token = credentials.credentials

    try:
        user_response = supabase.auth.get_user(token)
    except Exception as e:
        print("Supabase auth error:", e)
        raise HTTPException(status_code=401, detail="Invalid token")

    user_id = _extract_user_id(user_response)
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")

    try:
        supabase.auth.set_session(access_token=token, refresh_token="")
    except Exception as e:
        print("Supabase set_session error:", e)
        raise HTTPException(status_code=401, detail="Invalid token")

    return user_id
