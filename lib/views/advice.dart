import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrishow/views/user_input.dart';

class MacronutrientAdvicePage extends StatelessWidget {
  final Map<String, dynamic> foodDetails;

  const MacronutrientAdvicePage({super.key, required this.foodDetails});

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
                      "📝 Dietary Advice",
                        style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A6FA5),
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildTip("Eat a balanced diet with veggies and lean protein."),
                    _buildTip("Reduce sugary drinks and junk food."),
                    _buildTip("Drink enough water daily 💧."),
                    _buildTip("Exercise regularly for better metabolism! 🏃‍♀️"),
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
}
