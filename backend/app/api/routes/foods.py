from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.food_item import FoodItem
from app.schemas.food import FoodResponse

router = APIRouter()


@router.get("", response_model=list[FoodResponse])
def list_foods(db: Session = Depends(get_db)):
    return db.query(FoodItem).order_by(FoodItem.name.asc()).limit(100).all()


@router.get("/search", response_model=list[FoodResponse])
def search_foods(q: str, db: Session = Depends(get_db)):
    return (
        db.query(FoodItem)
        .filter(FoodItem.name.ilike(f"%{q}%"))
        .order_by(FoodItem.name.asc())
        .limit(20)
        .all()
    )
