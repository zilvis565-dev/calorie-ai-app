# Calorie AI App

Starter project for a calorie tracking application with AI-assisted meal parsing.

## Stack

- Backend: FastAPI
- Database: PostgreSQL
- Containerization: Docker Compose
- AI: placeholder parser service for future LLM integration

## Project structure

```text
backend/
  app/
    main.py
    core/
      config.py
    api/
      routes/
        health.py
        meals.py
    services/
      calorie_service.py
      ai_service.py
docker-compose.yml
.env.example
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
- `POST /api/meals/calculate`
- `POST /api/meals/parse`

## Next steps

- Add PostgreSQL models
- Add authentication
- Add food database and matching
- Add Flutter frontend
- Replace placeholder AI parser with real LLM integration
