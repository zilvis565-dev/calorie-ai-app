from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.core.config import settings
from app.db.session import get_db
from app.schemas.meal import MealCalculationRequest, MealCreateRequest, MealLogResponse, MealParseRequest
from app.services.ai_service import parse_meal_text
from app.services.auth_service import get_user_by_email
from app.services.calorie_service import calculate_meal_totals
from app.services.meal_service import create_meal_log, get_daily_summary, get_todays_meals

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


@router.post("/calculate")
def calculate_meal(request: MealCalculationRequest):
    return calculate_meal_totals(request.items)


@router.post("/parse")
def parse_meal(request: MealParseRequest):
    return parse_meal_text(request.text)


@router.post("", response_model=MealLogResponse)
def create_meal(request: MealCreateRequest, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user = get_current_user(token, db)
    return create_meal_log(db, user.id, request)


@router.get("/today", response_model=list[MealLogResponse])
def today_meals(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user = get_current_user(token, db)
    return get_todays_meals(db, user.id)


@router.get("/daily-summary")
def daily_summary(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user = get_current_user(token, db)
    return get_daily_summary(db, user.id)
