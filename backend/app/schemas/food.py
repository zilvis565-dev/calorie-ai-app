from pydantic import BaseModel


class FoodResponse(BaseModel):
    id: int
    name: str
    calories_per_100g: float
    protein_per_100g: float
    fat_per_100g: float
    carbs_per_100g: float

    class Config:
        from_attributes = True
