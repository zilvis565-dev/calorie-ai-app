from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.core.config import settings
from app.db.session import get_db
from app.schemas.user import UserResponse, UserUpdateRequest
from app.services.auth_service import get_user_by_email
from app.services.user_service import update_user_profile

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")


def get_current_user(token: str, db: Session):
    credentials_exception = HTTPException(status_code=401, detail="Could not validate credentials")
    try:
        payload = jwt.decode(token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm])
        email = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = get_user_by_email(db, email)
    if not user:
        raise credentials_exception
    return user


@router.get("/me", response_model=UserResponse)
def me(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    return get_current_user(token, db)


@router.put("/me", response_model=UserResponse)
def update_me(request: UserUpdateRequest, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user = get_current_user(token, db)
    return update_user_profile(db, user, request)
