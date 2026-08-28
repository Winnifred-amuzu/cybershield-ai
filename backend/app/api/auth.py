from fastapi import APIRouter, Depends, HTTPException, status

from ..auth.dependencies import get_current_user
from ..auth.security import create_access_token, hash_password, verify_password
from ..models.auth_schemas import AuthResponse, LoginRequest, RegisterRequest, UserResponse
from ..services.database import create_user, get_user_by_email

router = APIRouter(prefix="/auth", tags=["Authentication"])


def public_user(user):
    return {"id": user["id"], "name": user["name"], "email": user["email"], "created_at": user["created_at"]}


@router.post("/register", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
def register(request: RegisterRequest):
    if get_user_by_email(request.email.lower()):
        raise HTTPException(status_code=409, detail="An account with this email already exists")
    user = create_user(request.name.strip(), request.email.lower(), hash_password(request.password))
    token = create_access_token(user["id"], user["email"])
    return AuthResponse(access_token=token, user=public_user(user))


@router.post("/login", response_model=AuthResponse)
def login(request: LoginRequest):
    user = get_user_by_email(request.email.lower())
    if user is None or not verify_password(request.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    token = create_access_token(user["id"], user["email"])
    return AuthResponse(access_token=token, user=public_user(user))


@router.get("/me", response_model=UserResponse)
def me(user=Depends(get_current_user)):
    return public_user(user)
