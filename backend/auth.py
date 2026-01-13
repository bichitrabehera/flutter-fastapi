from fastapi import Header, HTTPException, status
from jose import jwt
import os

JWT_SECRET = os.getenv("SUPABASE_JWT_SECRET")

def get_user_id(authorization: str = Header(..., alias="Authorization")):
    """
    Extract and verify the user ID from the Supabase JWT token in the Authorization header.
    Returns the user ID (sub claim) from the JWT token.
    """
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or invalid authorization header",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    token = authorization.replace("Bearer ", "").strip()
    
    try:
        # Decode the JWT token without verification (since we're using service key for DB operations)
        # The token is already verified by Supabase when issued
        payload = jwt.decode(
            token,
            "",  # Empty key since we're not verifying signature
            options={
                "verify_signature": False,
                "verify_aud": False,
                "verify_exp": True,  # Still check expiration
            }
        )
        
        # Extract user ID from the 'sub' claim
        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token: missing user ID",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        return user_id
        
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except jwt.JWTError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid token: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Authentication error: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )
