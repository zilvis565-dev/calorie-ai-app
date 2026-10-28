from fastapi import APIRouter

from app.schemas.meal import MealCalculationRequest, MealParseRequest
from app.services.ai_service import parse_meal_text
from app.services.calorie_service import calculate_meal_totals

router = APIRouter()


@router.post("/calculate")
def calculate_meal(request: MealCalculationRequest):
    return calculate_meal_totals(request.items)


@router.post("/parse")
def parse_meal(request: MealParseRequest):
    return parse_meal_text(request.text)
