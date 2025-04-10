import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrishow/database/food_history.dart';
import 'package:nutrishow/views/advice.dart';
import 'package:nutrishow/utils/formatting.dart';

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
      body:
      Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/screensbg.png',
              fit: BoxFit.cover,
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(  // Using FutureBuilder to load data
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
                  final portionSize = double.tryParse(item['portionSize']?.toString() ?? '') ?? 1.0;

                  double parseDouble(dynamic value) {
                    if (value == null) return 0;
                    return double.tryParse(value.toString()) ?? 0;
                  }

                  double calories = parseDouble(foodDetails['energy_kcal']) * portionSize;
                  double protein = parseDouble(foodDetails['protein_g']) * portionSize;
                  double carbs = parseDouble(foodDetails['carbohydrates_g']) * portionSize;
                  double fat = parseDouble(foodDetails['total_fat_g']) * portionSize;
                  double sodium = parseDouble(foodDetails['sodium_mg']) * portionSize;


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
                                  Text(
                                    "🥣 ${formatValue(portionSize, item['portionSize']?.toString())} portion(s)",
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text("Calories: ${formatValue(calories, item['portionSize']?.toString())} kcal", style: GoogleFonts.nunito(fontSize:15)),
                                  Text("Protein: ${formatValue(protein, item['portionSize']?.toString())} g", style: GoogleFonts.nunito(fontSize:15)),
                                  Text("Carbs: ${formatValue(carbs, item['portionSize']?.toString())} g", style: GoogleFonts.nunito(fontSize:15)),
                                  Text("Fat: ${formatValue(fat, item['portionSize']?.toString())} g", style: GoogleFonts.nunito(fontSize:15)),
                                  Text("Sodium: ${formatValue(sodium, item['portionSize']?.toString())} g", style: GoogleFonts.nunito(fontSize:15)),


                                  const SizedBox(height: 8),
                                  Text(
                                    "🕒 ${DateTime.tryParse(item['timestamp'] ?? '')?.toLocal().toString().split('.')[0] ?? 'Unknown time'}",
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[700],
                                    ),
                                  ),
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
                                      pinnedTips: (item['pinnedTips'] as String?)?.split('|'),
                                      notice: item['notice'],
                                      activityLevel: foodDetails['activity_level'] ?? 'active',
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
        ],
      ),
    );
  }
}
