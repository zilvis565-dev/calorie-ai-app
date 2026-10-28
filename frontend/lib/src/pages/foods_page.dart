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

  @override
  void initState() {
    super.initState();
    loadFoods();
  }

  Future<void> loadFoods() async {
    final data = await apiClient.getFoods();
    setState(() {
      foods = data.map((e) => FoodItem.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<void> searchFoods() async {
    final query = searchController.text.trim();
    if (query.isEmpty) {
      await loadFoods();
      return;
    }
    final data = await apiClient.searchFoods(query);
    setState(() {
      foods = data.map((e) => FoodItem.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addMeal(FoodItem item) async {
    final controller = TextEditingController(text: '100');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${item.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Grams'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await apiClient.createMealFromFood(
                foodItemId: item.id,
                grams: double.tryParse(controller.text) ?? 100,
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
            child: ListView.builder(
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
