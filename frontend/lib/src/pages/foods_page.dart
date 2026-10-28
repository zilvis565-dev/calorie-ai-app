import 'package:flutter/material.dart';

import '../api_client.dart';
import '../models/food_item.dart';

class FoodsPage extends StatefulWidget {
  const FoodsPage({super.key});

  @override
  State<FoodsPage> createState() => _FoodsPageState();
}

class _FoodsPageState extends State<FoodsPage> {
  final searchController = TextEditingController();
  List<FoodItem> foods = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  Future<void> loadFoods() async {
    setState(() => loading = true);
    try {
      final data = await apiClient.getFoods();
      setState(() {
        foods = data.map((e) => FoodItem.fromJson(e as Map<String, dynamic>)).toList();
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> searchFoods() async {
    final query = searchController.text.trim();
    setState(() => loading = true);
    try {
      final data = query.isEmpty ? await apiClient.getFoods() : await apiClient.searchFoods(query);
      setState(() {
        foods = data.map((e) => FoodItem.fromJson(e as Map<String, dynamic>)).toList();
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> addMeal(FoodItem item) async {
    final gramsController = TextEditingController(text: '100');
    String mealType = 'snack';
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add ${item.name}'),
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
                await apiClient.createMealFromFood(
                  foodItemId: item.id,
                  grams: double.tryParse(gramsController.text) ?? 100,
                  mealType: mealType,
                );
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} added')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foods')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onSubmitted: (_) => searchFoods(),
                    decoration: const InputDecoration(
                      labelText: 'Search foods',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: searchFoods, child: const Text('Search')),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      final item = foods[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('${item.caloriesPer100g} kcal / 100g'),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => addMeal(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
