from sqlalchemy.orm import Session

from app.schemas.user import UserUpdateRequest


def update_user_profile(db: Session, user, request: UserUpdateRequest):
    data = request.model_dump(exclude_unset=True)
    for field, value in data.items():
        setattr(user, field, value)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user
