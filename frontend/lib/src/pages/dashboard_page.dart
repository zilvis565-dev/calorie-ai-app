import 'package:flutter/material.dart';

import '../api_client.dart';
import '../models/meal_log.dart';
import '../models/weekly_day_stats.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? summary;
  List<MealLog> meals = [];
  List<WeeklyDayStats> weeklyDays = [];
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
      final weeklyData = await apiClient.getWeeklyStats();
      setState(() {
        summary = summaryData;
        meals = mealsData.map((e) => MealLog.fromJson(e as Map<String, dynamic>)).toList();
        weeklyDays = ((weeklyData['days'] ?? []) as List)
            .map((e) => WeeklyDayStats.fromJson(e as Map<String, dynamic>))
            .toList();
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

  Widget buildWeeklyCards() {
    if (weeklyDays.isEmpty) {
      return const Text('No weekly stats yet.');
    }
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: weeklyDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = weeklyDays[index];
          final target = day.targetCalories;
          final progress = target != null && target > 0 ? (day.calories / target).clamp(0, 1).toDouble() : null;
          return SizedBox(
            width: 150,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(day.date, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${day.calories.toStringAsFixed(0)} kcal'),
                    if (progress != null) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: progress),
                    ],
                    const SizedBox(height: 8),
                    Text('P ${day.protein.toStringAsFixed(0)}  F ${day.fat.toStringAsFixed(0)}  C ${day.carbs.toStringAsFixed(0)}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildSummaryCard() {
    final calories = (summary?['calories'] ?? 0).toDouble();
    final targetRaw = summary?['target_calories'];
    final target = targetRaw is num ? targetRaw.toDouble() : null;
    final progress = target != null && target > 0 ? (calories / target).clamp(0, 1).toDouble() : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Calories: ${summary?['calories'] ?? 0}'),
            Text('Protein: ${summary?['protein'] ?? 0}'),
            Text('Fat: ${summary?['fat'] ?? 0}'),
            Text('Carbs: ${summary?['carbs'] ?? 0}'),
            Text('Target: ${summary?['target_calories'] ?? '-'}'),
            Text('Remaining: ${summary?['remaining_calories'] ?? '-'}'),
            if (progress != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress),
            ],
          ],
        ),
      ),
    );
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
                      buildSummaryCard(),
                      const SizedBox(height: 16),
                      const Text('Last 7 days', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      buildWeeklyCards(),
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
