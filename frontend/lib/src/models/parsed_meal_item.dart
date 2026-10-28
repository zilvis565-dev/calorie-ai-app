class ParsedMealItem {
  final String name;
  final double grams;
  final int? matchedFoodId;

  ParsedMealItem({
    required this.name,
    required this.grams,
    required this.matchedFoodId,
  });

  factory ParsedMealItem.fromJson(Map<String, dynamic> json) {
    return ParsedMealItem(
      name: json['name'] as String,
      grams: (json['grams'] as num).toDouble(),
      matchedFoodId: json['matched_food_id'] as int?,
    );
  }
}
