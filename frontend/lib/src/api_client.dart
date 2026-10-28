import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiClient {
  String? token;

  Map<String, String> get headers {
    final base = {'Content-Type': 'application/json'};
    if (token != null) {
      base['Authorization'] = 'Bearer $token';
    }
    return base;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/users/me'),
      headers: headers,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/users/me'),
      headers: headers,
      body: jsonEncode(payload),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getFoods() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/foods'),
      headers: headers,
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getDailySummary() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/meals/daily-summary'),
      headers: headers,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getTodayMeals() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/meals/today'),
      headers: headers,
    );
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> createMealFromFood({
    required int foodItemId,
    required double grams,
    String? mealType,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/meals/from-food'),
      headers: headers,
      body: jsonEncode({
        'food_item_id': foodItemId,
        'grams': grams,
        'meal_type': mealType,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

final apiClient = ApiClient();
