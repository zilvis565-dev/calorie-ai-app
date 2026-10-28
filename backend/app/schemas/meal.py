from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


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


class MealParseAndSaveRequest(BaseModel):
    text: str = Field(min_length=1)
    meal_type: str | None = None


class ParsedMealItem(BaseModel):
    name: str
    grams: float
    matched_food_id: int | None = None


class MealSaveParsedRequest(BaseModel):
    items: list[ParsedMealItem]
    meal_type: str | None = None


class MealCreateRequest(BaseModel):
    food_item_id: int | None = None
    name: str
    grams: float = Field(gt=0)
    calories: float = Field(ge=0)
    protein: float = Field(default=0, ge=0)
    fat: float = Field(default=0, ge=0)
    carbs: float = Field(default=0, ge=0)
    meal_type: str | None = None
    eaten_at: datetime | None = None


class MealCreateFromFoodRequest(BaseModel):
    food_item_id: int
    grams: float = Field(gt=0)
    meal_type: str | None = None
    eaten_at: datetime | None = None


class MealUpdateRequest(BaseModel):
    grams: float = Field(gt=0)
    meal_type: str | None = None


class MealLogResponse(BaseModel):
    id: UUID
    food_item_id: int | None = None
    name: str
    grams: float
    calories: float
    protein: float
    fat: float
    carbs: float
    meal_type: str | None = None
    eaten_at: datetime

    class Config:
        from_attributes = True
