from pydantic import BaseModel, EmailStr, Field, field_validator


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6, max_length=72)
    name: str | None = None

    @field_validator('password')
    @classmethod
    def validate_password(cls, value: str):
        if len(value.encode('utf-8')) > 72:
            raise ValueError('Password must be 72 bytes or fewer')
        return value


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=1, max_length=72)

    @field_validator('password')
    @classmethod
    def validate_password(cls, value: str):
        if len(value.encode('utf-8')) > 72:
            raise ValueError('Password must be 72 bytes or fewer')
        return value


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
