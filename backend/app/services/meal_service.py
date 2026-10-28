from datetime import date, datetime, time

from fastapi import HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.food_item import FoodItem
from app.models.meal_log import MealLog
from app.schemas.meal import MealCreateFromFoodRequest, MealCreateRequest


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


def create_meal_from_food(db: Session, user_id, request: MealCreateFromFoodRequest):
    food = db.query(FoodItem).filter(FoodItem.id == request.food_item_id).first()
    if not food:
        raise HTTPException(status_code=404, detail="Food item not found")

    grams = request.grams
    meal = MealLog(
        user_id=user_id,
        food_item_id=food.id,
        name=food.name,
        grams=grams,
        calories=round((food.calories_per_100g * grams) / 100, 2),
        protein=round((food.protein_per_100g * grams) / 100, 2),
        fat=round((food.fat_per_100g * grams) / 100, 2),
        carbs=round((food.carbs_per_100g * grams) / 100, 2),
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


def get_daily_summary(db: Session, user_id, daily_target=None):
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
    summary = {
        "calories": round(result[0], 2),
        "protein": round(result[1], 2),
        "fat": round(result[2], 2),
        "carbs": round(result[3], 2),
        "target_calories": daily_target,
        "remaining_calories": None,
    }
    if daily_target is not None:
        summary["remaining_calories"] = round(daily_target - result[0], 2)
    return summary


def get_meal_type_options():
    return ["breakfast", "lunch", "dinner", "snack"]
