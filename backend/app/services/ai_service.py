import re


def parse_meal_text(text: str):
    lower = text.lower()
    items = []

    patterns = [
        (r"(\d+)\s*egg", "Egg", 60, 1),
        (r"(\d+)\s*banana", "Banana", 120, 2),
        (r"(\d+)\s*apple", "Apple", 180, 7),
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

    if not items:
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
            if keyword in lower:
                items.append({
                    "name": name,
                    "grams": grams,
                    "matched_food_id": food_id,
                })

    return {
        "original_text": text,
        "message": "Rule-based parser placeholder. Replace with LLM integration.",
        "items": items,
    }
