def parse_meal_text(text: str):
    lower = text.lower()
    items = []

    mapping = [
        ("egg", "Egg", 120, 1),
        ("eggs", "Egg", 120, 1),
        ("banana", "Banana", 120, 2),
        ("apple", "Apple", 180, 7),
        ("bread", "Bread", 60, 6),
        ("rice", "Rice cooked", 100, 4),
        ("chicken", "Chicken breast", 150, 3),
        ("cheese", "Cheese", 30, 5),
        ("cottage cheese", "Cottage cheese", 150, 8),
    ]

    for keyword, name, grams, food_id in mapping:
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
