from fastapi import APIRouter
from pydantic import BaseModel, Field

from app.services.ai_service import parse_meal_text
from app.services.calorie_service import calculate_meal_totals

router = APIRouter()


class MealItemInput(BaseModel):
    name: str
    grams: float = Field(gt=0)
    calories_per_100g: float = Field(ge=0)
    protein_per_100g: float = Field(default=0, ge=0)
    fat_per_100g: float = Field(default=0, ge=0)
    carbs_per_100g: float = Field(default=0, ge=0)


class MealCalculationRequest(BaseModel):
    items: list[MealItemInput]


class MealParseRequest(BaseModel):
    text: str = Field(min_length=1)


@router.post("/calculate")
def calculate_meal(request: MealCalculationRequest):
    return calculate_meal_totals(request.items)


@router.post("/parse")
def parse_meal(request: MealParseRequest):
    return parse_meal_text(request.text)
