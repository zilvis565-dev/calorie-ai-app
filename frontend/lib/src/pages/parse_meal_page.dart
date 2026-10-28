import 'package:flutter/material.dart';

import '../api_client.dart';
import '../models/parsed_meal_item.dart';

class ParseMealPage extends StatefulWidget {
  const ParseMealPage({super.key});

  @override
  State<ParseMealPage> createState() => _ParseMealPageState();
}

class _ParseMealPageState extends State<ParseMealPage> {
  final textController = TextEditingController();
  List<ParsedMealItem> items = [];
  String? message;
  bool loading = false;
  String mealType = 'snack';

  Future<void> parseMeal() async {
    setState(() {
      loading = true;
      message = null;
    });
    try {
      final result = await apiClient.parseMealText(textController.text);
      setState(() {
        items = (result['items'] as List)
            .map((e) => ParsedMealItem.fromJson(e as Map<String, dynamic>))
            .toList();
        message = result['message'] as String?;
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> editAndSaveItem(int index) async {
    final item = items[index];
    if (item.matchedFoodId == null) return;

    final gramsController = TextEditingController(text: item.grams.toStringAsFixed(0));
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${item.name}'),
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
                  foodItemId: item.matchedFoodId!,
                  grams: double.tryParse(gramsController.text) ?? item.grams,
                  mealType: mealType,
                );
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} saved')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> refreshDashboardHint() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal saved. Go back to refresh dashboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Meal Input')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: textController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'What did you eat?',
                border: OutlineInputBorder(),
              ),
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
                if (value != null) setState(() => mealType = value);
              },
              decoration: const InputDecoration(labelText: 'Meal type'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loading ? null : parseMeal,
              child: Text(loading ? 'Parsing...' : 'Parse with AI'),
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(message!),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text('${item.grams} g'),
                      trailing: item.matchedFoodId != null
                          ? ElevatedButton(
                              onPressed: () async {
                                await editAndSaveItem(index);
                                await refreshDashboardHint();
                              },
                              child: const Text('Edit & Save'),
                            )
                          : const Text('No match'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
