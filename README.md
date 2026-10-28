# Calorie AI App

Starter project for a calorie tracking application with AI-assisted meal parsing.

## Stack

- Backend: FastAPI
- Database: PostgreSQL
- ORM: SQLAlchemy
- Auth: JWT
- Password hashing: Passlib
- Containerization: Docker Compose
- AI: placeholder parser service for future LLM integration

## Project structure

```text
backend/
  app/
    main.py
    db/
      base.py
      seed.py
      session.py
    core/
      config.py
      security.py
    api/
      routes/
        auth.py
        health.py
        foods.py
        meals.py
        users.py
    models/
      user.py
      food_item.py
      meal_log.py
    schemas/
      auth.py
      food.py
      meal.py
      user.py
    services/
      calorie_service.py
      ai_service.py
      auth_service.py
      meal_service.py
      user_service.py
```

## Endpoints

- `GET /health`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `GET /api/foods`
- `GET /api/foods/search?q=egg`
- `POST /api/meals`
- `POST /api/meals/from-food`
- `GET /api/meals/today`
- `GET /api/meals/daily-summary`
- `GET /api/users/me`
- `PUT /api/users/me`
- `POST /api/meals/calculate`
- `POST /api/meals/parse`

## Notes

- Database tables are created automatically at startup in this starter version.
- Basic food seed data is inserted automatically if the `food_items` table is empty.
- AI parser is still a placeholder and should be replaced with a real LLM integration.
- Daily summary now includes target calories and remaining calories when user profile target is set.
