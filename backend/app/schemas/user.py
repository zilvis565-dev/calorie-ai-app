from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, EmailStr


class UserResponse(BaseModel):
    id: UUID
    email: EmailStr
    name: str | None = None
    age: int | None = None
    height_cm: int | None = None
    daily_calorie_target: int | None = None
    created_at: datetime

    class Config:
        from_attributes = True
