from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.food_item import FoodItem
from app.schemas.food import FoodResponse
from app.services.food_search_service import external_search_foods, local_search_foods

router = APIRouter()


@router.get("", response_model=list[FoodResponse])
def list_foods(db: Session = Depends(get_db)):
    return db.query(FoodItem).order_by(FoodItem.name.asc()).limit(100).all()


@router.get("/search", response_model=list[FoodResponse])
def search_foods(q: str, db: Session = Depends(get_db)):
    results = local_search_foods(db, q, limit=20)
    return results


@router.get("/search-all")
def search_all_foods(q: str, db: Session = Depends(get_db)):
    local = local_search_foods(db, q, limit=10)
    external = external_search_foods(q)
    return {
        "local": [
            {
                "id": item.id,
                "name": item.name,
                "calories_per_100g": item.calories_per_100g,
                "protein_per_100g": item.protein_per_100g,
                "fat_per_100g": item.fat_per_100g,
                "carbs_per_100g": item.carbs_per_100g,
            }
            for item in local
        ],
        "external": external,
    }
