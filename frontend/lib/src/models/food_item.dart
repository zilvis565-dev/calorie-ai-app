class FoodItem {
  final int id;
  final String name;
  final double caloriesPer100g;

  FoodItem({
    required this.id,
    required this.name,
    required this.caloriesPer100g,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as int,
      name: json['name'] as String,
      caloriesPer100g: (json['calories_per_100g'] as num).toDouble(),
    );
  }
}
