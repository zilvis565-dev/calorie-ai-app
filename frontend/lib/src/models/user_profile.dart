class UserProfile {
  final String email;
  final String? name;
  final int? dailyCalorieTarget;

  UserProfile({
    required this.email,
    required this.name,
    required this.dailyCalorieTarget,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] as String,
      name: json['name'] as String?,
      dailyCalorieTarget: json['daily_calorie_target'] as int?,
    );
  }
}
