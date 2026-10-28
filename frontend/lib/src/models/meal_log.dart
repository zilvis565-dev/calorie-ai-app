class MealLog {
  final String id;
  final String name;
  final double grams;
  final double calories;
  final String? mealType;

  MealLog({
    required this.id,
    required this.name,
    required this.grams,
    required this.calories,
    required this.mealType,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['id'] as String,
      name: json['name'] as String,
      grams: (json['grams'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      mealType: json['meal_type'] as String?,
    );
  }
}
