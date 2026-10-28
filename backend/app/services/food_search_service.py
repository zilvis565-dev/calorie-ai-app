from difflib import SequenceMatcher

from app.core.config import settings
from app.models.food_item import FoodItem


def normalize_name(value: str) -> str:
    return (
        value.lower()
        .replace('ą', 'a')
        .replace('č', 'c')
        .replace('ę', 'e')
        .replace('ė', 'e')
        .replace('į', 'i')
        .replace('š', 's')
        .replace('ų', 'u')
        .replace('ū', 'u')
        .replace('ž', 'z')
        .strip()
    )


def local_search_foods(db, query: str, limit: int = 10):
    items = db.query(FoodItem).all()
    qn = normalize_name(query)
    scored = []
    for item in items:
        name_n = normalize_name(item.name)
        score = SequenceMatcher(None, qn, name_n).ratio()
        if qn in name_n:
            score += 0.4
        scored.append((score, item))
    scored.sort(key=lambda x: x[0], reverse=True)
    return [item for score, item in scored[:limit] if score > 0.25]


def external_search_foods(query: str):
    provider = settings.food_provider.lower().strip()
    if provider == 'local':
        return {
            'provider': 'local',
            'items': []
        }
    return {
        'provider': provider,
        'message': 'External food provider scaffold is ready. Add provider request logic and API credentials.',
        'items': []
    }


def find_best_food_match(db, query: str):
    local = local_search_foods(db, query, limit=1)
    if local:
        return local[0]
    return None
