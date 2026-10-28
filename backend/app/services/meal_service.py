from datetime import date, datetime, time

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.meal_log import MealLog
from app.schemas.meal import MealCreateRequest


def create_meal_log(db: Session, user_id, request: MealCreateRequest):
    meal = MealLog(
        user_id=user_id,
        food_item_id=request.food_item_id,
        name=request.name,
        grams=request.grams,
        calories=request.calories,
        protein=request.protein,
        fat=request.fat,
        carbs=request.carbs,
        meal_type=request.meal_type,
        eaten_at=request.eaten_at or datetime.utcnow(),
    )
    db.add(meal)
    db.commit()
    db.refresh(meal)
    return meal


def get_todays_meals(db: Session, user_id):
    today = date.today()
    start = datetime.combine(today, time.min)
    end = datetime.combine(today, time.max)
    return (
        db.query(MealLog)
        .filter(MealLog.user_id == user_id)
        .filter(MealLog.eaten_at >= start)
        .filter(MealLog.eaten_at <= end)
        .order_by(MealLog.eaten_at.desc())
        .all()
    )


def get_daily_summary(db: Session, user_id):
    today = date.today()
    start = datetime.combine(today, time.min)
    end = datetime.combine(today, time.max)
    result = (
        db.query(
            func.coalesce(func.sum(MealLog.calories), 0),
            func.coalesce(func.sum(MealLog.protein), 0),
            func.coalesce(func.sum(MealLog.fat), 0),
            func.coalesce(func.sum(MealLog.carbs), 0),
        )
        .filter(MealLog.user_id == user_id)
        .filter(MealLog.eaten_at >= start)
        .filter(MealLog.eaten_at <= end)
        .first()
    )
    return {
        "calories": round(result[0], 2),
        "protein": round(result[1], 2),
        "fat": round(result[2], 2),
        "carbs": round(result[3], 2),
    }
