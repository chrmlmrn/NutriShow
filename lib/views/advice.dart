import 'package:flutter/material.dart';

class MacronutrientAdvicePage extends StatelessWidget {
  final Map<String, dynamic> foodDetails;

  const MacronutrientAdvicePage({super.key, required this.foodDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(width: 3, color: Colors.black)),
                      ),
                      child: Text(
                        "Calories ${foodDetails['calories'] ?? 'Unknown'}",
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildNutrientRow("Total Fat", foodDetails['total_fat'], "g", bold: true),
                    _buildSubNutrient("Saturated Fat", foodDetails['saturated_fat'], "g"),
                    _buildSubNutrient("Polyunsaturated Fat", foodDetails['polyunsaturated_fat'], "g"),
                    _buildSubNutrient("Monounsaturated Fat", foodDetails['monounsaturated_fat'], "g"),
                    _buildNutrientRow("Cholesterol", foodDetails['cholesterol'], "mg"),
                    _buildNutrientRow("Sodium", foodDetails['sodium'], "mg"),
                    _buildNutrientRow("Total Carbohydrates", foodDetails['total_carbohydrates'], "g", bold: true),
                    _buildSubNutrient("Dietary Fiber", foodDetails['dietary_fiber'], "g"),
                    _buildSubNutrient("Sugar", foodDetails['sugar'], "g"),
                    _buildNutrientRow("Protein", foodDetails['protein'], "g", bold: true),
                    const Divider(thickness: 2, color: Colors.black),

                    _buildNutrientRow("Vitamin D", foodDetails['vitamin_d'], "mcg"),
                    _buildNutrientRow("Calcium", foodDetails['calcium'], "mg"),
                    _buildNutrientRow("Iron", foodDetails['iron'], "mg"),
                    _buildNutrientRow("Potassium", foodDetails['potassium'], "mg"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.withOpacity(0.2),
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Dietary Advice",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "- Eat a balanced diet rich in vegetables and lean proteins.",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "- Reduce intake of saturated fats and sugars to maintain heart health.",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "- Ensure adequate fiber intake to aid digestion.",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      "- Drink plenty of water throughout the day.",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String name, dynamic value, String unit, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "${value ?? 'Unknown'} $unit",
            style: TextStyle(
              fontSize: 18,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
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
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            "${value ?? 'Unknown'} $unit",
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
