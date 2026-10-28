# Calorie AI App

Starter project for a calorie tracking application with AI-assisted meal parsing.

## Stack

- Backend: FastAPI
- Database: PostgreSQL
- ORM: SQLAlchemy
- Auth: JWT
- Password hashing: Passlib
- Frontend: Flutter
- Containerization: Docker Compose
- AI: placeholder parser service for future LLM integration

## Project structure

```text
backend/
frontend/
```

## Frontend features

- Login page
- Register page
- Dashboard page
- Food list page
- Add meal from food page
- Profile page

## Backend endpoints used by frontend

- `POST /api/auth/register`
- `POST /api/auth/login`
- `GET /api/users/me`
- `PUT /api/users/me`
- `GET /api/foods`
- `GET /api/foods/search?q=egg`
- `POST /api/meals/from-food`
- `GET /api/meals/today`
- `GET /api/meals/daily-summary`
