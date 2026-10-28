from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.food_item import FoodItem


DEFAULT_FOODS = [
    {"name": "Egg", "calories_per_100g": 143, "protein_per_100g": 13, "fat_per_100g": 10, "carbs_per_100g": 1.1},
    {"name": "Banana", "calories_per_100g": 89, "protein_per_100g": 1.1, "fat_per_100g": 0.3, "carbs_per_100g": 22.8},
    {"name": "Chicken breast", "calories_per_100g": 165, "protein_per_100g": 31, "fat_per_100g": 3.6, "carbs_per_100g": 0},
    {"name": "Rice cooked", "calories_per_100g": 130, "protein_per_100g": 2.7, "fat_per_100g": 0.3, "carbs_per_100g": 28},
    {"name": "Cheese", "calories_per_100g": 350, "protein_per_100g": 25, "fat_per_100g": 27, "carbs_per_100g": 1.3},
    {"name": "Bread", "calories_per_100g": 265, "protein_per_100g": 9, "fat_per_100g": 3.2, "carbs_per_100g": 49},
    {"name": "Apple", "calories_per_100g": 52, "protein_per_100g": 0.3, "fat_per_100g": 0.2, "carbs_per_100g": 14},
    {"name": "Cottage cheese", "calories_per_100g": 98, "protein_per_100g": 11.1, "fat_per_100g": 4.3, "carbs_per_100g": 3.4},
    {"name": "Greek yogurt", "calories_per_100g": 97, "protein_per_100g": 9, "fat_per_100g": 5, "carbs_per_100g": 3.8},
    {"name": "Blueberries", "calories_per_100g": 57, "protein_per_100g": 0.7, "fat_per_100g": 0.3, "carbs_per_100g": 14.5},
    {"name": "Peanut butter", "calories_per_100g": 588, "protein_per_100g": 25, "fat_per_100g": 50, "carbs_per_100g": 20},
    {"name": "Oats", "calories_per_100g": 389, "protein_per_100g": 16.9, "fat_per_100g": 6.9, "carbs_per_100g": 66.3},
    {"name": "Milk", "calories_per_100g": 52, "protein_per_100g": 3.4, "fat_per_100g": 2, "carbs_per_100g": 4.8},
    {"name": "Skyr", "calories_per_100g": 63, "protein_per_100g": 11, "fat_per_100g": 0.2, "carbs_per_100g": 4},
]


def seed_food_items(db: Session):
    existing_names = set(db.execute(select(FoodItem.name)).scalars().all())
    inserted = False
    for item in DEFAULT_FOODS:
        if item["name"] not in existing_names:
            db.add(FoodItem(**item))
            inserted = True
    if inserted:
        db.commit()
