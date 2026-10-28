from fastapi import FastAPI

from app.api.routes.auth import router as auth_router
from app.api.routes.health import router as health_router
from app.api.routes.meals import router as meals_router
from app.db.base import Base
from app.db.session import engine
from app.core.config import settings

Base.metadata.create_all(bind=engine)

app = FastAPI(title=settings.app_name)

app.include_router(health_router)
app.include_router(auth_router, prefix="/api/auth", tags=["auth"])
app.include_router(meals_router, prefix="/api/meals", tags=["meals"])
