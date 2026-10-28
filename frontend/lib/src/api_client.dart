import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
  }

  Future<void> saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    token = value;
    await prefs.setString('auth_token', value);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = null;
    await prefs.remove('auth_token');
  }

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  Future<Map<String, dynamic>> _handleJsonResponse(http.Response response) async {
    final data = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      return {'error': true, 'detail': data['detail']?.toString() ?? 'Request failed'};
    }
    return data;
  }

  Future<List<dynamic>> _handleJsonListResponse(http.Response response) async {
    if (response.statusCode >= 400) {
      return [];
    }
    return jsonDecode(response.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = await _handleJsonResponse(response);
    if (data['access_token'] != null) {
      await saveToken(data['access_token'] as String);
    }
    return data;
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    return _handleJsonResponse(response);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/users/me'),
      headers: headers,
    );
    return _handleJsonResponse(response);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/users/me'),
      headers: headers,
      body: jsonEncode(payload),
    );
    return _handleJsonResponse(response);
  }

  Future<List<dynamic>> getFoods() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/foods'),
      headers: headers,
    );
    return _handleJsonListResponse(response);
  }

  Future<List<dynamic>> searchFoods(String query) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/foods/search?q=$query'),
      headers: headers,
    );
    return _handleJsonListResponse(response);
  }

  Future<Map<String, dynamic>> getDailySummary() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/meals/daily-summary'),
      headers: headers,
    );
    return _handleJsonResponse(response);
  }

  Future<List<dynamic>> getTodayMeals() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/meals/today'),
      headers: headers,
    );
    return _handleJsonListResponse(response);
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
    return _handleJsonResponse(response);
  }

  Future<Map<String, dynamic>> parseMealText(String text) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/meals/parse'),
      headers: headers,
      body: jsonEncode({'text': text}),
    );
    return _handleJsonResponse(response);
  }
}

final apiClient = ApiClient();
