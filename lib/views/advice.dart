import 'package:flutter/material.dart';

class MacronutrientAdvicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NutriShow Advice"),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Personalized Dietary Advice",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "• You are consuming an excess amount of protein. Consider moderating your intake to align with your needs.\n"
                      "• Your carbohydrate intake is significantly below the recommended level. Adding whole grains or fruits to your meals could help.\n"
                      "• Your fat consumption is slightly above the recommended range. Focus on healthy fats like avocados or nuts in moderation.\n"
                      "• Vitamin C levels are likely below optimal. Include citrus fruits or bell peppers in your meals.\n"
                      "• Omega-3 fatty acids might be lacking. Adding fatty fish like salmon could help address this.\n",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
