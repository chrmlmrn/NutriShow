import 'package:flutter/material.dart';
import 'package:nutrishow/database/food_history.dart';
import 'package:nutrishow/views/advice.dart';

class FoodHistoryPage extends StatelessWidget {
  const FoodHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Food History"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: FoodHistory.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No food history yet.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final history = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  tileColor: Colors.white,
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.pinkAccent,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    item['food_name'] ?? "Unknown Dish",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text("Calories: ${item['calories'] ?? 'Unknown'} kcal"),
                      Text("Protein: ${item['protein'] ?? 'Unknown'} g"),
                      Text("Carbs: ${item['total_carbohydrates'] ?? 'Unknown'} g"),
                      Text("Fat: ${item['total_fat'] ?? 'Unknown'} g"),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MacronutrientAdvicePage(foodDetails: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
