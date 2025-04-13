import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrishow/database/food_history.dart';
import 'package:nutrishow/views/advice.dart';
import 'package:nutrishow/utils/formatting.dart';
import 'package:fl_chart/fl_chart.dart';

class FoodHistoryPage extends StatelessWidget {
  const FoodHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FEEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FEEB),
        iconTheme: const IconThemeData(color: Color(0xFF0E4A06), size: 30),
        title: Text(
          'Food History',
          style: GoogleFonts.nunito(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0E4A06),
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/screensbg.png',
              fit: BoxFit.cover,
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
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

              double totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;

              for (var item in history) {
                final portionSize = double.tryParse(item['portionSize']?.toString() ?? '') ?? 1.0;
                final food = item['foodDetails'] ?? {};

                double parseDouble(dynamic value) {
                  if (value == null) return 0;
                  return double.tryParse(value.toString()) ?? 0;
                }

                totalCalories += parseDouble(food['energy_kcal']) * portionSize;
                totalProtein += parseDouble(food['protein_g']) * portionSize;
                totalCarbs += parseDouble(food['carbohydrates_g']) * portionSize;
                totalFat += parseDouble(food['total_fat_g']) * portionSize;
              }

              final nutrientSections = [
                PieChartSectionData(
                  value: totalCalories,
                  title: '',
                  color: const Color(0xFFABCB4D),
                  radius: 90,
                ),
                PieChartSectionData(
                  value: totalProtein,
                  title: '',
                  color: const Color(0xFF5D8736),
                  radius: 90,
                ),
                PieChartSectionData(
                  value: totalCarbs,
                  title: '',
                  color: const Color(0xFFFFDA5C),
                  radius: 90,
                ),
                PieChartSectionData(
                  value: totalFat,
                  title: '',
                  color: const Color(0xFFAAD3C4),
                  radius: 90,
                ),
              ];

              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Total Nutrients Breakdown",
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0E4A06),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: nutrientSections,
                        centerSpaceRadius: 0,
                        sectionsSpace: 4,
                      ),
                    ),
                  ),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 14, height: 14, decoration: BoxDecoration(color: Color(0xFFABCB4D), shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text("Calories: ${totalCalories.toStringAsFixed(2)} kcal", style: GoogleFonts.nunito(fontSize: 15)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 14, height: 14, decoration: BoxDecoration(color: Color(0xFF5D8736), shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text("Protein: ${totalProtein.toStringAsFixed(2)} g", style: GoogleFonts.nunito(fontSize: 15)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 14, height: 14, decoration: BoxDecoration(color: Color(0xFFFFDA5C), shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text("Carbs: ${totalCarbs.toStringAsFixed(2)} g", style: GoogleFonts.nunito(fontSize: 15)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 14, height: 14, decoration: BoxDecoration(color: Color(0xFFAAD3C4), shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text("Fat: ${totalFat.toStringAsFixed(2)} g", style: GoogleFonts.nunito(fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  ...List.generate(history.length, (index) {
                    final item = history[index];
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

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                          side: const BorderSide(color: Color(0xFFafb992), width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFD3F1DF),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFAAD3C4),
                                child: Text(
                                  '${index + 1}',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF0E4A06),
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
                                  color: const Color(0xFF0E4A06),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("🥣 ${formatValue(portionSize, item['portionSize']?.toString())} portion(s)", style: GoogleFonts.nunito(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.black87)),
                                  const SizedBox(height: 8),
                                  Text("Calories: ${formatValue(calories, item['portionSize']?.toString())} kcal", style: GoogleFonts.nunito(fontSize: 15)),
                                  Text("Protein: ${formatValue(protein, item['portionSize']?.toString())} g", style: GoogleFonts.nunito(fontSize: 15)),
                                  Text("Carbs: ${formatValue(carbs, item['portionSize']?.toString())} g", style: GoogleFonts.nunito(fontSize: 15)),
                                  Text("Fat: ${formatValue(fat, item['portionSize']?.toString())} g", style: GoogleFonts.nunito(fontSize: 15)),
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
                              trailing: const Icon(Icons.arrow_forward_ios, size: 24, color: Color(0xFF0E4A06)),
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
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
