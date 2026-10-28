class WeeklyDayStats {
  final String date;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final int? targetCalories;

  WeeklyDayStats({
    required this.date,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.targetCalories,
  });

  factory WeeklyDayStats.fromJson(Map<String, dynamic> json) {
    return WeeklyDayStats(
      date: json['date'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      targetCalories: json['target_calories'] as int?,
    );
  }
}
