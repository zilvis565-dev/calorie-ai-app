# Calorie AI App

AI-assisted calorie tracker starter with FastAPI backend, PostgreSQL database, Flutter frontend, and a simple mobile-friendly web UI.

## Included backend features

- JWT authentication
- User profile endpoints
- Food list and food search
- Smarter local food matching with Lithuanian character normalization
- Food provider scaffold for future large external databases
- Meal creation from food item
- Save multiple parsed meal items in one request
- Parse and save meal text in one request
- Meal update and delete
- Meal history by date range
- Weekly stats for last 7 days
- Daily summary with remaining calories
- Rule-based AI parser with better multi-item phrase matching
- Better Lithuanian quantity parsing for `liesa varske`, `graikiskas jogurtas`, `silauoges`, `riesutu sviestas`, `bananas`
- LLM integration scaffold with provider config
- Alembic migration setup
- Safer auth validation for password length handling
- Switched auth hashing to `pbkdf2_sha256` for more stable local compatibility
- Swagger OAuth2 authorize flow aligned with login endpoint
- Fixed meal response schema UUID typing
- Simple mobile-friendly web UI available at `/web`
