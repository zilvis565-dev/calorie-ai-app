class MealLog {
  final String id;
  final String name;
  final double grams;
  final double calories;

  MealLog({
    required this.id,
    required this.name,
    required this.grams,
    required this.calories,
  });

  factory MealLog.fromJson(Map<String, dynamic> json) {
    return MealLog(
      id: json['id'] as String,
      name: json['name'] as String,
      grams: (json['grams'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
    );
  }
}
