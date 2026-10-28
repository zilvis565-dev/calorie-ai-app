from fastapi import FastAPI

from app.api.routes.auth import router as auth_router
from app.api.routes.foods import router as foods_router
from app.api.routes.health import router as health_router
from app.api.routes.meals import router as meals_router
from app.api.routes.users import router as users_router
from app.db.seed import seed_food_items
from app.db.session import SessionLocal
from app.core.config import settings

with SessionLocal() as db:
    seed_food_items(db)

app = FastAPI(title=settings.app_name)

app.include_router(health_router)
app.include_router(auth_router, prefix="/api/auth", tags=["auth"])
app.include_router(users_router, prefix="/api/users", tags=["users"])
app.include_router(foods_router, prefix="/api/foods", tags=["foods"])
app.include_router(meals_router, prefix="/api/meals", tags=["meals"])
