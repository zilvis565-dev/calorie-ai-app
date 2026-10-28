from datetime import date

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.core.config import settings
from app.db.session import get_db
from app.schemas.meal import (
    MealCalculationRequest,
    MealCreateFromFoodRequest,
    MealCreateRequest,
    MealLogResponse,
    MealParseAndSaveRequest,
    MealParseRequest,
    MealSaveParsedRequest,
    MealUpdateRequest,
)
from app.services.ai_service import parse_meal_text
from app.services.auth_service import get_user_by_email
from app.services.calorie_service import calculate_meal_totals
from app.services.meal_service import (
    create_meal_from_food,
    create_meal_log,
    delete_meal,
    get_daily_summary,
    get_meal_history,
    get_todays_meals,
    get_weekly_stats,
    save_parsed_meals,
    update_meal,
)

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


@router.post("/parse-and-save")
def parse_and_save(request: MealParseAndSaveRequest, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user = get_current_user(token, db)
    parsed = parse_meal_text(request.text)
    items = parsed.get("items", [])
    save_request = MealSaveParsedRequest(items=items, meal_type=request.meal_type)
    saved = save_parsed_meals(db, user.id, save_request)
    return {
        "provider": parsed.get("provider"),
        "message": parsed.get("message"),
        "parsed_items": items,
        "saved": saved,
    }


@router.post("/save-parsed")
def save_parsed(request: MealSaveParsedRequest, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user = get_current_user(token, db)
    return save_parsed_meals(db, user.id, request)


@router.post("", response_model=MealLogResponse)
def create_meal(request: MealCreateRequest, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user = get_current_user(token, db)
    return create_meal_log(db, user.id, request)


@router.post("/from-food", response_model=MealLogResponse)
def create_meal_by_food(request: MealCreateFromFoodRequest, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user = get_current_user(token, db)
    return create_meal_from_food(db, user.id, request)


@router.get("/today", response_model=list[MealLogResponse])
def today_meals(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user = get_current_user(token, db)
    return get_todays_meals(db, user.id)


@router.get("/history", response_model=list[MealLogResponse])
def meal_history(
    from_date: date = Query(..., alias='from'),
    to_date: date = Query(..., alias='to'),
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
):
    user = get_current_user(token, db)
    return get_meal_history(db, user.id, from_date, to_date)


@router.get("/weekly-stats")
def weekly_stats(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user = get_current_user(token, db)
    return get_weekly_stats(db, user.id, user.daily_calorie_target)


@router.get("/daily-summary")
def daily_summary(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user = get_current_user(token, db)
    return get_daily_summary(db, user.id, user.daily_calorie_target)


@router.put("/{meal_id}", response_model=MealLogResponse)
def edit_meal(meal_id: str, request: MealUpdateRequest, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user = get_current_user(token, db)
    return update_meal(db, meal_id, user.id, request)


@router.delete("/{meal_id}")
def remove_meal(meal_id: str, token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    user = get_current_user(token, db)
    return delete_meal(db, meal_id, user.id)
