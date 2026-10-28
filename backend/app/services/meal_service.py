from datetime import date, datetime, time, timedelta
from uuid import UUID

from fastapi import HTTPException
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.models.food_item import FoodItem
from app.models.meal_log import MealLog
from app.schemas.meal import MealCreateFromFoodRequest, MealCreateRequest, MealUpdateRequest


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


def get_meal_history(db: Session, user_id, from_date: date, to_date: date):
    start = datetime.combine(from_date, time.min)
    end = datetime.combine(to_date, time.max)
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


def get_weekly_stats(db: Session, user_id, daily_target=None):
    today = date.today()
    start_date = today - timedelta(days=6)
    start = datetime.combine(start_date, time.min)
    end = datetime.combine(today, time.max)

    rows = (
        db.query(MealLog)
        .filter(MealLog.user_id == user_id)
        .filter(MealLog.eaten_at >= start)
        .filter(MealLog.eaten_at <= end)
        .order_by(MealLog.eaten_at.asc())
        .all()
    )

    daily_map = {}
    for i in range(7):
        day = start_date + timedelta(days=i)
        daily_map[day.isoformat()] = {
            "date": day.isoformat(),
            "calories": 0.0,
            "protein": 0.0,
            "fat": 0.0,
            "carbs": 0.0,
            "target_calories": daily_target,
        }

    for row in rows:
        key = row.eaten_at.date().isoformat()
        if key in daily_map:
            daily_map[key]["calories"] += row.calories
            daily_map[key]["protein"] += row.protein
            daily_map[key]["fat"] += row.fat
            daily_map[key]["carbs"] += row.carbs

    items = list(daily_map.values())
    total_calories = sum(item["calories"] for item in items)
    avg_calories = total_calories / 7

    return {
        "days": [
            {
                "date": item["date"],
                "calories": round(item["calories"], 2),
                "protein": round(item["protein"], 2),
                "fat": round(item["fat"], 2),
                "carbs": round(item["carbs"], 2),
                "target_calories": item["target_calories"],
            }
            for item in items
        ],
        "total_calories": round(total_calories, 2),
        "average_calories": round(avg_calories, 2),
    }


def update_meal(db: Session, meal_id: str, user_id, request: MealUpdateRequest):
    meal = db.query(MealLog).filter(MealLog.id == UUID(meal_id), MealLog.user_id == user_id).first()
    if not meal:
        raise HTTPException(status_code=404, detail="Meal not found")

    meal.grams = request.grams
    if request.meal_type is not None:
        meal.meal_type = request.meal_type

    if meal.food_item_id:
        food = db.query(FoodItem).filter(FoodItem.id == meal.food_item_id).first()
        if food:
            meal.calories = round((food.calories_per_100g * meal.grams) / 100, 2)
            meal.protein = round((food.protein_per_100g * meal.grams) / 100, 2)
            meal.fat = round((food.fat_per_100g * meal.grams) / 100, 2)
            meal.carbs = round((food.carbs_per_100g * meal.grams) / 100, 2)

    db.add(meal)
    db.commit()
    db.refresh(meal)
    return meal


def delete_meal(db: Session, meal_id: str, user_id):
    meal = db.query(MealLog).filter(MealLog.id == UUID(meal_id), MealLog.user_id == user_id).first()
    if not meal:
        raise HTTPException(status_code=404, detail="Meal not found")
    db.delete(meal)
    db.commit()
    return {"success": True}
