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
