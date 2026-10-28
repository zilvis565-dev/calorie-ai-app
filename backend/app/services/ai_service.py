import json
import re

from app.core.config import settings


def rule_based_parse(text: str):
    lower = text.lower()
    items = []

    patterns = [
        (r"(\d+)\s*egg[s]?", "Egg", 60, 1),
        (r"(\d+)\s*banana[s]?", "Banana", 120, 2),
        (r"(\d+)\s*apple[s]?", "Apple", 180, 7),
        (r"(\d+)\s*slice[s]?\s*bread", "Bread", 30, 6),
        (r"(\d+)\s*g\s*rice", "Rice cooked", 1, 4),
        (r"(\d+)\s*g\s*chicken", "Chicken breast", 1, 3),
        (r"(\d+)\s*g\s*cheese", "Cheese", 1, 5),
        (r"(\d+)\s*g\s*cottage cheese", "Cottage cheese", 1, 8),
    ]

    for pattern, name, gram_factor, food_id in patterns:
        for match in re.finditer(pattern, lower):
            value = int(match.group(1))
            items.append({
                "name": name,
                "grams": value * gram_factor,
                "matched_food_id": food_id,
            })

    fallback = [
        ("egg", "Egg", 120, 1),
        ("banana", "Banana", 120, 2),
        ("apple", "Apple", 180, 7),
        ("bread", "Bread", 60, 6),
        ("rice", "Rice cooked", 100, 4),
        ("chicken", "Chicken breast", 150, 3),
        ("cheese", "Cheese", 30, 5),
        ("cottage cheese", "Cottage cheese", 150, 8),
    ]

    for keyword, name, grams, food_id in fallback:
        if keyword in lower and not any(item["name"] == name for item in items):
            items.append({
                "name": name,
                "grams": grams,
                "matched_food_id": food_id,
            })

    ordered = []
    seen = set()
    for item in items:
        key = (item["name"], item["grams"])
        if key not in seen:
            seen.add(key)
            ordered.append(item)

    return {
        "original_text": text,
        "message": "Rule-based parser placeholder. Parsed multiple matching food phrases when possible.",
        "provider": "rule-based",
        "items": ordered,
    }


def llm_parse(text: str):
    prompt = {
        "instruction": "Extract food items from the user's text and return JSON only.",
        "schema": {
            "items": [
                {"name": "string", "grams": "number", "matched_food_id": "number or null"}
            ]
        },
        "input": text,
    }
    return {
        "original_text": text,
        "message": "LLM integration scaffold is ready. Set AI_PROVIDER and implement provider request logic.",
        "provider": settings.ai_provider,
        "prompt_preview": json.dumps(prompt),
        "items": [],
    }


def parse_meal_text(text: str):
    provider = settings.ai_provider.lower().strip()
    if provider in {"openai", "anthropic", "gemini", "custom"}:
        return llm_parse(text)
    return rule_based_parse(text)
