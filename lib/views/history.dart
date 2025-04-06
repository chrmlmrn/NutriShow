import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrishow/database/food_history.dart';
import 'package:nutrishow/views/advice.dart';

class FoodHistoryPage extends StatelessWidget {
  const FoodHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FEEB),
      appBar: AppBar(
        backgroundColor: Color(0xFFF9FEEB),
        iconTheme: IconThemeData(color: Color(0xFF0E4A06), size: 30),
        title: Text(
          'Food History',
          style: GoogleFonts.nunito(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0E4A06),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(  // Using FutureBuilder to load data
        future: FoodHistory.getHistory(),  // Fetching food history from the database
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

              // Extract stored structure
              final foodDetails = item['foodDetails'] ?? {};
              final assessment = item['assessment'];
              final recommendedIntake = item['recommendedIntake'];
              final gender = item['gender'];
              final portionSize = double.tryParse(item['portionSize']?.toString() ?? '1') ?? 1;

              // Adjust nutritional values using portion size
              double calories = (foodDetails['energy_kcal'] ?? 0) * portionSize;
              double protein = (foodDetails['protein_g'] ?? 0) * portionSize;
              double carbs = (foodDetails['carbohydrates_g'] ?? 0) * portionSize;
              double fat = (foodDetails['total_fat_g'] ?? 0) * portionSize;


              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(
                      color: Color(0xFFafb992),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFD3F1DF),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFAAD3C4),
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.poppins(
                              color: Color(0xFF0E4A06),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          foodDetails['food_name'] ?? "Unknown Dish",
                          style: GoogleFonts.poppins(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0E4A06),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text("Calories: ${calories.toStringAsFixed(2)} kcal", style: GoogleFonts.nunito(fontSize:15)),
                            Text("Protein: ${protein.toStringAsFixed(2)} g", style: GoogleFonts.nunito(fontSize:15)),
                            Text("Carbs: ${carbs.toStringAsFixed(2)} g", style: GoogleFonts.nunito(fontSize:15)),
                            Text("Fat: ${fat.toStringAsFixed(2)} g", style: GoogleFonts.nunito(fontSize:15)),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 24,
                          color: Color(0xFF0E4A06),
                        ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MacronutrientAdvicePage(
                                  foodDetails: foodDetails,
                                  assessment: assessment,
                                  recommendedIntake: recommendedIntake,
                                  gender: gender,
                                  portionSize: item['portionSize'],
                                  tip: item['tip'], // <-- Add this
                                ),
                              ),
                            );
                          }
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
