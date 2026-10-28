import 'package:flutter/material.dart';

import '../api_client.dart';
import '../models/meal_log.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? summary;
  List<MealLog> meals = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    try {
      final summaryData = await apiClient.getDailySummary();
      final mealsData = await apiClient.getTodayMeals();
      setState(() {
        summary = summaryData;
        meals = mealsData.map((e) => MealLog.fromJson(e as Map<String, dynamic>)).toList();
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/parse-meal');
              await loadData();
            },
            icon: const Icon(Icons.auto_awesome),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/foods');
              await loadData();
            },
            icon: const Icon(Icons.restaurant),
          ),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/profile'), icon: const Icon(Icons.person)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Calories: ${summary?['calories'] ?? 0}'),
                          Text('Protein: ${summary?['protein'] ?? 0}'),
                          Text('Fat: ${summary?['fat'] ?? 0}'),
                          Text('Carbs: ${summary?['carbs'] ?? 0}'),
                          Text('Target: ${summary?['target_calories'] ?? '-'}'),
                          Text('Remaining: ${summary?['remaining_calories'] ?? '-'}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Today meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...meals.map(
                    (meal) => ListTile(
                      title: Text(meal.name),
                      subtitle: Text('${meal.grams} g • ${meal.id.substring(0, 8)}'),
                      trailing: Text('${meal.calories} kcal'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
