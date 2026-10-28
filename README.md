# Calorie AI App

This repository now contains a fuller MVP starter for an AI-assisted calorie tracker with FastAPI backend, PostgreSQL database, and Flutter frontend.【cite§source0.0】

## Included backend features

- JWT authentication
- User profile endpoints
- Food list and food search
- Meal creation from food item
- Daily summary with remaining calories
- Rule-based AI placeholder meal parser

## Included frontend features

- Splash screen with auto-login
- Login and registration
- Dashboard with summary and today's meals
- Food search and add flow
- Profile update and logout
- AI text meal parsing flow with edit before save
- Loading and basic error states

## iOS support

- `frontend/lib/src/api_config.dart` is configured for iOS Simulator with `http://127.0.0.1:8000`
- `frontend/ios/Runner/Info.plist` allows HTTP local development traffic
- For physical iPhone testing, replace `127.0.0.1` with your Mac LAN IP

## Recommended next future step

- Replace rule-based parser with real LLM integration
- Add Alembic migrations
- Add secure token refresh flow
- Add native barcode scanner or photo meal detection
