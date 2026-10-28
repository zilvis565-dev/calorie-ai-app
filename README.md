# Calorie AI App

AI-assisted calorie tracker starter with FastAPI backend, PostgreSQL database, and Flutter frontend.

## Included backend features

- JWT authentication
- User profile endpoints
- Food list and food search
- Meal creation from food item
- Meal update and delete
- Meal history by date range
- Weekly stats for last 7 days
- Daily summary with remaining calories
- Rule-based AI parser with better multi-item phrase matching
- LLM integration scaffold with provider config
- Alembic migration setup

## AI configuration scaffold

Environment variables added:

- `AI_PROVIDER`
- `AI_API_KEY`
- `AI_MODEL`

Current behavior:

- `AI_PROVIDER=mock` uses the existing rule-based parser
- setting provider to values like `openai`, `anthropic`, `gemini`, or `custom` switches backend to LLM scaffold mode
- scaffold mode currently returns provider information and prompt preview structure so real provider wiring can be added later

## Included frontend features

- Splash screen with auto-login
- Login and registration
- Dashboard with summary and today's meals
- Weekly stats cards on dashboard
- Progress bars for daily target and weekly cards
- Food search and add flow
- Profile update and logout
- AI text meal parsing flow with edit before save
- Meal history screen with better empty/error states
- Loading and basic error states
