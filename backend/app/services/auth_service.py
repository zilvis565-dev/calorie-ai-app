from sqlalchemy.orm import Session

from app.core.security import create_access_token, hash_password, verify_password
from app.models.user import User
from app.schemas.auth import RegisterRequest


def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()


def create_user(db: Session, request: RegisterRequest):
    password = request.password.strip()
    if len(password.encode('utf-8')) > 72:
        raise ValueError('Password must be 72 bytes or fewer')

    user = User(
        email=request.email,
        password_hash=hash_password(password),
        name=request.name,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def authenticate_user(db: Session, email: str, password: str):
    if len(password.encode('utf-8')) > 72:
        raise ValueError('Password must be 72 bytes or fewer')

    user = get_user_by_email(db, email)
    if not user or not verify_password(password, user.password_hash):
        return None
    return create_access_token(user.email)
