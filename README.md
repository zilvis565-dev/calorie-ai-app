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
      session.py
    core/
      config.py
      security.py
    api/
      routes/
        auth.py
        health.py
        meals.py
    models/
      user.py
      food_item.py
      meal_log.py
    schemas/
      auth.py
      meal.py
      user.py
    services/
      calorie_service.py
      ai_service.py
      auth_service.py
```

## Quick start

1. Copy environment file:

```bash
cp .env.example .env
```

2. Start services:

```bash
docker compose up --build
```

3. Open API docs:

- http://localhost:8000/docs

## Endpoints

- `GET /health`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/auth/me`
- `POST /api/meals/calculate`
- `POST /api/meals/parse`

## Notes

- Database tables are created automatically at startup in this starter version.
- AI parser is still a placeholder and should be replaced with a real LLM integration.
- Next step: add food seed data and meal persistence endpoints.
