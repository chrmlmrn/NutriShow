import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrishow/views/user_input.dart';

class MacronutrientAdvicePage extends StatelessWidget {
  final Map<String, dynamic> foodDetails;
  final Map<String, dynamic>? assessment;
  final Map<String, dynamic>? recommendedIntake;
  final String? gender;


  const MacronutrientAdvicePage({super.key, required this.foodDetails, this.assessment, this.recommendedIntake, this.gender});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FEEB),
      appBar: AppBar(
        backgroundColor: Color(0xFFF9FEEB),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF0E4A06), size: 30),
        title: Text(
          'Dietary Assessment',
          style: GoogleFonts.nunito(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF0E4A06)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home_rounded),
            tooltip: 'Home',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const UserInputView()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                foodDetails['food_name']?.toString().toUpperCase() ?? "Unknown Food",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E4A06),
                ),
              ),
              const SizedBox(height: 12),
              _buildNutritionFactsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderRow("🔥 Calories", "${foodDetails['energy_kcal'] ?? 'Unknown'} kcal"),
                    SizedBox(height: 10),
                    _buildNutrientRow("🍗 Protein", foodDetails['protein_g'], "g"),
                    _buildNutrientRow("🍞 Total Carbohydrates", foodDetails['carbohydrates_g'], "g"),
                    _buildSubNutrient("🌿 Fiber", foodDetails['fiber_g'], "g"),
                    _buildSubNutrient("🍬 Total Sugars", foodDetails['total_sugars_g'], "g"),
                    _buildNutrientRow("🥑 Total Fats", foodDetails['total_fat_g'], "g"),

                    Divider(thickness: 1.5, color: Colors.black26),

                    _buildCategoryHeader("Minerals"),
                    _buildNutrientRow("🧂 Sodium", foodDetails['sodium_mg'], "mg"),
                    _buildNutrientRow("🥛 Calcium", foodDetails['calcium_mg'], "mg"),
                    _buildNutrientRow("🩸 Iron", foodDetails['iron_mg'], "mg"),
                    _buildNutrientRow("🍌 Potassium", foodDetails['potassium_mg'], "mg"),
                    _buildNutrientRow("⚡ Zinc", foodDetails['zinc_mg'], "mg"),

                    Divider(thickness: 1.5, color: Colors.black26),

                    _buildCategoryHeader("Vitamins"),
                    _buildNutrientRow("🍃 Folate", foodDetails['folate_ug'], "mcg"),
                    _buildNutrientRow("🍊 Vitamin C", foodDetails['vitamin_c_mg'], "mg"),
                    _buildNutrientRow("🥩 Vitamin B-6", foodDetails['vitamin_b6_mg'], "mg"),
                    _buildNutrientRow("👀 Vitamin A", foodDetails['vitamin_a_ug'], "mcg"),
                    _buildNutrientRow("🥜 Vitamin E", foodDetails['vitamin_e_mg'], "mg"),
                    _buildNutrientRow("🥬 Vitamin K", foodDetails['vitamin_k_ug'], "mcg"),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _buildDietaryAdviceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "📝 Dietary Assessment",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A6FA5),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      "Too much nutrients (${(assessment?['too_much'] as List?)?.length ?? 0}):",
                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    if ((assessment?['too_much'] as List?)?.isEmpty ?? true)
                      Text("• None", style: GoogleFonts.nunito(fontSize: 16))
                    else
                      ...List.generate(
                        (assessment!['too_much'] as List).length,
                            (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text("• ${assessment!['too_much'][index]}", style: GoogleFonts.nunito(fontSize: 16)),
                        ),
                      ),

                    const SizedBox(height: 12),

                    Text(
                      "Lacking nutrients (${(assessment?['lacking'] as List?)?.length ?? 0}):",
                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    if ((assessment?['lacking'] as List?)?.isEmpty ?? true)
                      Text("• None", style: GoogleFonts.nunito(fontSize: 16))
                    else
                      ...List.generate(
                        (assessment!['lacking'] as List).length,
                            (index) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Text("• ${assessment!['lacking'][index]}", style: GoogleFonts.nunito(fontSize: 16)),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      "Recommended Nutrient Intake:",
                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),

                    if (recommendedIntake != null)
                      ..._buildRecommendedIntakeList(recommendedIntake!)
                    else
                      Text("• Not available", style: GoogleFonts.nunito(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionFactsCard({required Widget child, Color? color, Color borderColor = const Color(0xFFA9C46C)}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDietaryAdviceCard({required Widget child, Color? color, Color borderColor = const Color(0xFF23649e)}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0XFFCFE3DA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildHeaderRow(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:  Color(0xFFFFDA5C),
      ),
      child: Center(
        child: Text(
          "$title: $value",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF68662A),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0E4A06),
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String name, dynamic value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          Text(
            "${value ?? 'Unknown'} $unit",
            style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildSubNutrient(String name, dynamic value, String unit) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: GoogleFonts.nunito(fontSize: 16, fontStyle: FontStyle.italic),
          ),
          Text(
            "${value ?? 'Unknown'} $unit",
            style: GoogleFonts.nunito(fontSize: 16, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.nunito(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRecommendedIntakeList(Map<String, dynamic> intake) {
    final isMale = gender?.toLowerCase().startsWith('m') ?? true;

    final nutrientsToShow = {
      "energy_${isMale ? 'm' : 'f'}_a": "Energy",
      "protein_${isMale ? 'm' : 'f'}": "Protein",
      "carbohydrates_${isMale ? 'm' : 'f'}_a_min": "Carbohydrates",
      "fiber_min": "Fiber",
      "total_sugars_${isMale ? 'm' : 'f'}_a": "Total Sugars",
      "total_fat_${isMale ? 'm' : 'f'}_a_max": "Total Fat",
      "sodium": "Sodium",
      "iron_${isMale ? 'm' : 'f'}": "Iron",
      "zinc_${isMale ? 'm' : 'f'}": "Zinc",
      "vitamin_c_${isMale ? 'm' : 'f'}": "Vitamin C",
      "vitamin_b6_${isMale ? 'm' : 'f'}": "Vitamin B6",
      "folate_${isMale ? 'm' : 'f'}": "Folate",
      "vitamin_a_${isMale ? 'm' : 'f'}": "Vitamin A",
      "vitamin_e_${isMale ? 'm' : 'f'}": "Vitamin E",
      "vitamin_k_${isMale ? 'm' : 'f'}": "Vitamin K",
      "calcium_${isMale ? 'm' : 'f'}": "Calcium",
      "potassium": "Potassium",
    };

    return nutrientsToShow.entries.map((entry) {
      final value = intake[entry.key];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Text(
          "• ${entry.value}: ${value ?? '—'}",
          style: GoogleFonts.nunito(fontSize: 16),
        ),
      );
    }).toList();
  }


}