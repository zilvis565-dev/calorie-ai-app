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

  Future<void> parseMeal() async {
    setState(() {
      loading = true;
      message = null;
    });
    final result = await apiClient.parseMealText(textController.text);
    setState(() {
      items = (result['items'] as List)
          .map((e) => ParsedMealItem.fromJson(e as Map<String, dynamic>))
          .toList();
      message = result['message'] as String?;
      loading = false;
    });
  }

  Future<void> saveItem(ParsedMealItem item) async {
    if (item.matchedFoodId == null) return;
    await apiClient.createMealFromFood(
      foodItemId: item.matchedFoodId!,
      grams: item.grams,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.name} saved')),
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
                              onPressed: () => saveItem(item),
                              child: const Text('Save'),
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
