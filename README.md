# Calorie AI App

Starter project for a calorie tracking application with AI-assisted meal parsing.

## Stack

- Backend: FastAPI
- Database: PostgreSQL
- ORM: SQLAlchemy
- Auth: JWT
- Password hashing: Passlib
- Frontend: Flutter
- Local persistence: shared_preferences
- Containerization: Docker Compose
- AI: rule-based placeholder parser service for future LLM integration

## iOS note

For iOS simulator, frontend uses `http://127.0.0.1:8000` as the API base URL. For a physical iPhone, change it to your Mac local network IP in `frontend/lib/src/api_config.dart`.

## Frontend features

- Splash screen with auto-login from saved token
- Login page
- Register page
- Dashboard page
- Food list page with search
- Profile page with logout
- AI meal parse page
- Parsed meal review and save flow

## Example AI text inputs

- `2 eggs`
- `150g chicken`
- `2 slices bread`
- `100g rice and 30g cheese`
