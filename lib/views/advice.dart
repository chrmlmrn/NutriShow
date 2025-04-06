import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrishow/views/user_input.dart';
import 'dart:math';

class MacronutrientAdvicePage extends StatelessWidget {
  final Map<String, dynamic> foodDetails;
  final Map<String, dynamic>? assessment;
  final Map<String, dynamic>? recommendedIntake;
  final String? gender;
  final String? portionSize;
  final String? tip;
  final String? notice;

  const MacronutrientAdvicePage({
    super.key,
    required this.foodDetails,
    this.assessment,
    this.recommendedIntake,
    this.gender,
    this.portionSize,
    this.tip,
    this.notice,
  });

  double _adjustForPortion(dynamic value) {
    // Ensure the value is a double
    double nutrientValue = double.tryParse(value.toString()) ?? 0.0; // Ensure it's a valid double

    // If portion size is "1" or valid, return the value as is
    if (portionSize == null || portionSize == "1") {
      return nutrientValue;
    }

    // Handle fractional values like "1/2"
    if (portionSize!.contains("/")) {
      final parts = portionSize!.split("/");
      if (parts.length == 2) {
        double numerator = double.tryParse(parts[0]) ?? 1;
        double denominator = double.tryParse(parts[1]) ?? 1;
        return nutrientValue * (numerator / denominator);
      }
    }

    // Otherwise, treat it as a regular number
    double portionMultiplier = double.tryParse(portionSize!) ?? 1;
    return nutrientValue * portionMultiplier;
  }


  @override
  Widget build(BuildContext context) {
    final adjustedFoodDetails = {
      for (final entry in foodDetails.entries)
        entry.key: entry.value is num ? _adjustForPortion(entry.value) : entry.value,
    };

    final List<String> _dietTips = [
      "Please make sure to cut the nutrient intake for those with too much and consume more for those lacking/less.",
      "Make necessary dietary changes by limiting overconsumed nutrients and increasing those that are lacking.",
      "Improve your nutrient balance by eating less of what’s excessive and more of what’s insufficient.",
      "Moderate your nutrient levels—reduce excesses and supplement deficiencies accordingly.",
      "Ensure proper nutrition by decreasing overconsumed nutrients and boosting underconsumed ones.",
      "Regulate your diet by lowering excessive nutrients and increasing those in short supply.",
      "Optimize your nutrient intake by consuming less of what’s excessive and more of what’s insufficient.",
      "Maintain a healthy balance by reducing nutrients that exceed recommendations and increasing those that fall short.",
      "Keep your nutrient intake in check by lowering what’s too much and adding what’s too little.",
      "Ensure a well-rounded diet by consuming less of what you have too much of and more of what you need.",
      "Correct imbalances in your diet by lowering high nutrient levels and raising low ones.",
      "Manage your nutrition by reducing excessive intake and boosting nutrients that are below recommended levels.",
      "Strive for a balanced diet by cutting down on overconsumed nutrients and replenishing deficiencies.",
      "Adjust your food choices to decrease excess nutrients and increase those that are lacking.",
      "Make dietary adjustments by limiting excess nutrients and incorporating more of the ones you’re missing.",
    ];

    final String finalTip = tip ?? _dietTips[Random().nextInt(_dietTips.length)];

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
                foodDetails['food_name']?.toString().toUpperCase() ?? "UNKNOWN FOOD",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0E4A06),
                ),
              ),
              if (portionSize != null &&
                  portionSize!.isNotEmpty &&
                  foodDetails['serving_size'] != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    "Portion Size: $portionSize serving(s) • ${_calculateTotalGrams()} grams",
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              _buildNutritionFactsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderRow("🔥 Calories", "${_adjustForPortion(foodDetails['energy_kcal'] ?? 0)} kcal"),
                    SizedBox(height: 10),
                    _buildNutrientRow("🍗 Protein", _adjustForPortion(foodDetails['protein_g'] ?? 0), "g"),
                    _buildNutrientRow("🍞 Total Carbohydrates", _adjustForPortion(foodDetails['carbohydrates_g'] ?? 0), "g"),
                    _buildSubNutrient("🌿 Fiber", _adjustForPortion(foodDetails['fiber_g'] ?? 0), "g"),
                    _buildSubNutrient("🍬 Total Sugars", _adjustForPortion(foodDetails['total_sugars_g'] ?? 0), "g"),
                    _buildNutrientRow("🥑 Total Fats", _adjustForPortion(foodDetails['total_fat_g'] ?? 0), "g"),

                    Divider(thickness: 1.5, color: Colors.black26),

                    _buildCategoryHeader("Minerals"),
                    _buildNutrientRow("🧂 Sodium", _adjustForPortion(foodDetails['sodium_mg'] ?? 0), "mg"),
                    _buildNutrientRow("🥛 Calcium", _adjustForPortion(foodDetails['calcium_mg'] ?? 0), "mg"),
                    _buildNutrientRow("🩸 Iron", _adjustForPortion(foodDetails['iron_mg'] ?? 0), "mg"),
                    _buildNutrientRow("🍌 Potassium", _adjustForPortion(foodDetails['potassium_mg'] ?? 0), "mg"),
                    _buildNutrientRow("⚡ Zinc", _adjustForPortion(foodDetails['zinc_mg'] ?? 0), "mg"),

                    Divider(thickness: 1.5, color: Colors.black26),

                    _buildCategoryHeader("Vitamins"),
                    _buildNutrientRow("🍃 Folate", _adjustForPortion(foodDetails['folate_ug'] ?? 0), "μg"),
                    _buildNutrientRow("🍊 Vitamin C", _adjustForPortion(foodDetails['vitamin_c_mg'] ?? 0), "mg"),
                    _buildNutrientRow("🥩 Vitamin B-6", _adjustForPortion(foodDetails['vitamin_b6_mg'] ?? 0), "mg"),
                    _buildNutrientRow("👀 Vitamin A", _adjustForPortion(foodDetails['vitamin_a_ug'] ?? 0), "μg"),
                    _buildNutrientRow("🥜 Vitamin E", _adjustForPortion(foodDetails['vitamin_e_mg'] ?? 0), "mg"),
                    _buildNutrientRow("🥬 Vitamin K", _adjustForPortion(foodDetails['vitamin_k_ug'] ?? 0), "μg"),
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
                    if (notice != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          "ℹ️ $notice",
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ),
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
                      ...[
                        ..._buildRecommendedIntakeList(recommendedIntake!),
                        const SizedBox(height: 12),
                        Text(
                          "📌 $finalTip",
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ]
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
              "${(value as num?)?.toStringAsFixed(3) ?? 'Unknown'} $unit",
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
            "${(value as num?)?.toStringAsFixed(3) ?? 'Unknown'} $unit",
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
      "energy_${isMale ? 'm' : 'f'}_a": ["Energy", "kcal"],
      "protein_${isMale ? 'm' : 'f'}": ["Protein", "g"],
      "carbohydrates_${isMale ? 'm' : 'f'}_a_min": ["Carbohydrates", "g"],
      "fiber_min": ["Fiber", "g"],
      "total_sugars_${isMale ? 'm' : 'f'}_a": ["Total Sugars", "g"],
      "total_fat_${isMale ? 'm' : 'f'}_a_max": ["Total Fat", "g"],
      "sodium": ["Sodium", "mg"],
      "iron_${isMale ? 'm' : 'f'}": ["Iron", "mg"],
      "zinc_${isMale ? 'm' : 'f'}": ["Zinc", "mg"],
      "vitamin_c_${isMale ? 'm' : 'f'}": ["Vitamin C", "mg"],
      "vitamin_b6_${isMale ? 'm' : 'f'}": ["Vitamin B6", "mg"],
      "folate_${isMale ? 'm' : 'f'}": ["Folate", "μg"],
      "vitamin_a_${isMale ? 'm' : 'f'}": ["Vitamin A", "μg"],
      "vitamin_e_${isMale ? 'm' : 'f'}": ["Vitamin E", "mg"],
      "vitamin_k_${isMale ? 'm' : 'f'}": ["Vitamin K", "μg"],
      "calcium_${isMale ? 'm' : 'f'}": ["Calcium", "mg"],
      "potassium": ["Potassium", "mg"],
    };

    return nutrientsToShow.entries.map((entry) {
      final value = intake[entry.key];
      final nutrientName = entry.value[0];
      final unit = entry.value[1];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Text(
          "• $nutrientName: ${value ?? '—'} $unit",
          style: GoogleFonts.nunito(fontSize: 16),
        ),
      );
    }).toList();
  }

  String _calculateTotalGrams() {
    final baseServing = double.tryParse(foodDetails['serving_size'].toString()) ?? 0;
    double multiplier = 1.0;

    if (portionSize != null) {
      if (portionSize!.contains("/")) {
        final parts = portionSize!.split("/");
        if (parts.length == 2) {
          double numerator = double.tryParse(parts[0]) ?? 1;
          double denominator = double.tryParse(parts[1]) ?? 1;
          multiplier = numerator / denominator;
        }
      } else {
        multiplier = double.tryParse(portionSize!) ?? 1.0;
      }
    }

    return (baseServing * multiplier).toStringAsFixed(1);
  }

}
