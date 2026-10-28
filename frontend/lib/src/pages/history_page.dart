import 'package:flutter/material.dart';

import '../api_client.dart';
import '../models/meal_log.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  List<MealLog> meals = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    fromController.text = weekAgo.toIso8601String().split('T').first;
    toController.text = now.toIso8601String().split('T').first;
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() => loading = true);
    try {
      final data = await apiClient.getMealHistory(fromController.text, toController.text);
      setState(() {
        meals = data.map((e) => MealLog.fromJson(e as Map<String, dynamic>)).toList();
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: fromController,
                  decoration: const InputDecoration(labelText: 'From date (YYYY-MM-DD)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: toController,
                  decoration: const InputDecoration(labelText: 'To date (YYYY-MM-DD)'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: loadHistory, child: const Text('Load history')),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return ListTile(
                        title: Text(meal.name),
                        subtitle: Text('${meal.grams} g • ${meal.mealType ?? 'snack'}'),
                        trailing: Text('${meal.calories} kcal'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
