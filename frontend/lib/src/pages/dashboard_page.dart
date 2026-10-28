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
  String? error;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final summaryData = await apiClient.getDailySummary();
      if (summaryData['error'] == true) {
        setState(() => error = summaryData['detail']?.toString() ?? 'Failed to load summary');
        return;
      }
      final mealsData = await apiClient.getTodayMeals();
      setState(() {
        summary = summaryData;
        meals = mealsData.map((e) => MealLog.fromJson(e as Map<String, dynamic>)).toList();
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> editMeal(MealLog meal) async {
    final gramsController = TextEditingController(text: meal.grams.toStringAsFixed(0));
    String mealType = meal.mealType ?? 'snack';
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${meal.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: gramsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Grams'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: mealType,
                items: const [
                  DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
                  DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                  DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                  DropdownMenuItem(value: 'snack', child: Text('Snack')),
                ],
                onChanged: (value) {
                  if (value != null) setDialogState(() => mealType = value);
                },
                decoration: const InputDecoration(labelText: 'Meal type'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final result = await apiClient.updateMeal(
                  mealId: meal.id,
                  grams: double.tryParse(gramsController.text) ?? meal.grams,
                  mealType: mealType,
                );
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result['error'] == true ? 'Failed to update meal' : 'Meal updated')),
                );
                await loadData();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteMeal(MealLog meal) async {
    final result = await apiClient.deleteMeal(meal.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['error'] == true ? 'Failed to delete meal' : 'Meal deleted')),
    );
    await loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/history');
            },
            icon: const Icon(Icons.history),
          ),
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
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
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
                      if (meals.isEmpty) const Text('No meals added today yet.'),
                      ...meals.map(
                        (meal) => Card(
                          child: ListTile(
                            title: Text(meal.name),
                            subtitle: Text('${meal.grams} g • ${meal.mealType ?? 'snack'}'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  editMeal(meal);
                                } else if (value == 'delete') {
                                  deleteMeal(meal);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
