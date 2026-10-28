import json
import re
from typing import Any

import requests

from app.core.config import settings


def rule_based_parse(text: str):
    lower = text.lower()
    items = []

    patterns = [
        (r"(\d+)\s*egg[s]?", "Egg", 60, 1),
        (r"(\d+)\s*banana[s]?", "Banana", 120, 2),
        (r"(\d+)\s*bananas", "Banana", 120, 2),
        (r"(\d+)\s*apple[s]?", "Apple", 180, 7),
        (r"(\d+)\s*slice[s]?\s*bread", "Bread", 30, 6),
        (r"(\d+)\s*g\s*rice", "Rice cooked", 1, 4),
        (r"(\d+)\s*g\s*chicken", "Chicken breast", 1, 3),
        (r"(\d+)\s*g\s*cheese", "Cheese", 1, 5),
        (r"(\d+)\s*g\s*cottage cheese", "Cottage cheese", 1, 8),
        (r"(\d+)\s*g\s*greek yogurt", "Greek yogurt", 1, 9),
        (r"(\d+)\s*g\s*blueberries", "Blueberries", 1, 10),
        (r"(\d+)\s*g\s*peanut butter", "Peanut butter", 1, 11),
        (r"(\d+)\s*g\s*oats", "Oats", 1, 12),
        (r"(\d+)\s*g\s*milk", "Milk", 1, 13),
        (r"(\d+)\s*g\s*skyr", "Skyr", 1, 14),
        (r"(\d+)\s*g\s*liesa varske", "Cottage cheese", 1, 8),
        (r"(\d+)\s*g\s*liesos varskes", "Cottage cheese", 1, 8),
        (r"(\d+)\s*g\s*varske", "Cottage cheese", 1, 8),
        (r"(\d+)\s*g\s*varskes", "Cottage cheese", 1, 8),
        (r"(\d+)\s*g\s*graikiskas jogurtas", "Greek yogurt", 1, 9),
        (r"(\d+)\s*g\s*graikisko jogurto", "Greek yogurt", 1, 9),
        (r"(\d+)\s*g\s*melynes", "Blueberries", 1, 10),
        (r"(\d+)\s*g\s*silauoges", "Blueberries", 1, 10),
        (r"(\d+)\s*g\s*silauogiu", "Blueberries", 1, 10),
        (r"(\d+)\s*g\s*riesutu sviestas", "Peanut butter", 1, 11),
        (r"(\d+)\s*g\s*riesutu sviesto", "Peanut butter", 1, 11),
        (r"(\d+)\s*g\s*avizos", "Oats", 1, 12),
        (r"(\d+)\s*g\s*pienas", "Milk", 1, 13),
        (r"(\d+)\s*bananas", "Banana", 120, 2),
        (r"(\d+)\s*bananu", "Banana", 120, 2),
    ]

    for pattern, name, gram_factor, food_id in patterns:
        for match in re.finditer(pattern, lower):
            value = int(match.group(1))
            items.append({
                "name": name,
                "grams": float(value * gram_factor),
                "matched_food_id": food_id,
            })

    fallback = [
        ("egg", "Egg", 120, 1),
        ("banana", "Banana", 120, 2),
        ("bananas", "Banana", 120, 2),
        ("bananu", "Banana", 120, 2),
        ("apple", "Apple", 180, 7),
        ("bread", "Bread", 60, 6),
        ("rice", "Rice cooked", 100, 4),
        ("chicken", "Chicken breast", 150, 3),
        ("cheese", "Cheese", 30, 5),
        ("cottage cheese", "Cottage cheese", 150, 8),
        ("greek yogurt", "Greek yogurt", 150, 9),
        ("blueberries", "Blueberries", 80, 10),
        ("peanut butter", "Peanut butter", 20, 11),
        ("oats", "Oats", 50, 12),
        ("milk", "Milk", 200, 13),
        ("skyr", "Skyr", 150, 14),
        ("liesa varske", "Cottage cheese", 150, 8),
        ("liesos varskes", "Cottage cheese", 150, 8),
        ("varske", "Cottage cheese", 150, 8),
        ("varskes", "Cottage cheese", 150, 8),
        ("graikiskas jogurtas", "Greek yogurt", 150, 9),
        ("graikisko jogurto", "Greek yogurt", 150, 9),
        ("melynes", "Blueberries", 80, 10),
        ("silauoges", "Blueberries", 80, 10),
        ("silauogiu", "Blueberries", 80, 10),
        ("riesutu sviestas", "Peanut butter", 20, 11),
        ("riesutu sviesto", "Peanut butter", 20, 11),
        ("avizos", "Oats", 50, 12),
        ("pienas", "Milk", 200, 13),
    ]

    for keyword, name, grams, food_id in fallback:
        if keyword in lower and not any(item["name"] == name for item in items):
            items.append({
                "name": name,
                "grams": float(grams),
                "matched_food_id": food_id,
            })

    ordered = []
    seen = set()
    for item in items:
        key = (item["name"], item["grams"], item["matched_food_id"])
        if key not in seen:
            seen.add(key)
            ordered.append(item)

    return {
        "original_text": text,
        "message": "Rule-based parser fallback used.",
        "provider": "rule-based",
        "items": ordered,
    }


def build_llm_prompt(text: str) -> str:
    prompt = {
        "task": "Extract food items from the user's meal text.",
        "rules": [
            "Return only valid JSON.",
            "Use the schema exactly.",
            "Prefer explicit grams if stated.",
            "If quantity is not in grams, estimate grams conservatively.",
            "Do not add explanations.",
        ],
        "schema": {
            "items": [
                {"name": "string", "grams": "number", "matched_food_id": None}
            ]
        },
        "input": text,
    }
    return json.dumps(prompt, ensure_ascii=False)


def parse_gemini_json(text: str):
    api_key = settings.ai_api_key.strip()
    model = settings.ai_model.strip() or 'gemini-1.5-flash'
    if not api_key:
        raise ValueError('Gemini API key is missing')

    url = f'https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}'
    payload = {
        'contents': [
            {
                'parts': [
                    {'text': build_llm_prompt(text)}
                ]
            }
        ],
        'generationConfig': {
            'temperature': 0.2,
            'responseMimeType': 'application/json'
        }
    }

    response = requests.post(url, json=payload, timeout=30)
    response.raise_for_status()
    data = response.json()

    candidates = data.get('candidates', [])
    if not candidates:
        raise ValueError('Gemini returned no candidates')

    parts = candidates[0].get('content', {}).get('parts', [])
    if not parts:
        raise ValueError('Gemini returned no content parts')

    raw_text = ''.join(part.get('text', '') for part in parts).strip()
    parsed = json.loads(raw_text)
    items = parsed.get('items', [])

    normalized_items = []
    for item in items:
        name = item.get('name')
        grams = item.get('grams')
        if not name or grams is None:
            continue
        normalized_items.append({
            'name': str(name),
            'grams': float(grams),
            'matched_food_id': item.get('matched_food_id'),
        })

    return {
        'original_text': text,
        'message': 'Gemini parse used.',
        'provider': 'gemini',
        'mode': 'llm-live',
        'items': normalized_items,
    }


def llm_parse(text: str):
    provider = settings.ai_provider.lower().strip()
    if provider == 'gemini':
        return parse_gemini_json(text)

    return {
        'original_text': text,
        'message': 'LLM integration scaffold is ready. Set AI_PROVIDER, AI_API_KEY, AI_MODEL and implement provider request logic.',
        'provider': provider,
        'mode': 'llm-scaffold',
        'items': [],
    }


def parse_meal_text(text: str):
    provider = settings.ai_provider.lower().strip()
    if provider in {'openai', 'anthropic', 'gemini', 'custom'}:
        try:
            llm_result = llm_parse(text)
            fallback_result = rule_based_parse(text)
            return {
                **llm_result,
                'fallback_items': fallback_result.get('items', []),
            }
        except Exception as exc:
            fallback_result = rule_based_parse(text)
            return {
                **fallback_result,
                'provider': provider,
                'mode': 'fallback-after-llm-error',
                'message': f'AI parse failed, fallback used: {exc}',
            }
    return rule_based_parse(text)
