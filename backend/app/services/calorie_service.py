def calculate_item(item):
    grams = item.grams
    return {
        "name": item.name,
        "grams": grams,
        "calories": round((item.calories_per_100g * grams) / 100, 2),
        "protein": round((item.protein_per_100g * grams) / 100, 2),
        "fat": round((item.fat_per_100g * grams) / 100, 2),
        "carbs": round((item.carbs_per_100g * grams) / 100, 2),
    }


def calculate_meal_totals(items):
    calculated = [calculate_item(item) for item in items]
    totals = {
        "calories": round(sum(i["calories"] for i in calculated), 2),
        "protein": round(sum(i["protein"] for i in calculated), 2),
        "fat": round(sum(i["fat"] for i in calculated), 2),
        "carbs": round(sum(i["carbs"] for i in calculated), 2),
    }
    return {"items": calculated, "totals": totals}
