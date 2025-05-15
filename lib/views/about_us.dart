import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  final List<String> recognizableFoods = [
    "Adobong Sitaw", "Apple", "Avocado", "Banana", "Banana Cue",
    "Boiled Egg", "Brown Rice", "Caesar Salad", "Chicken Breast", "Chicken Curry",
    "Chopsuey", "Corn", "Daing na Bangus", "Dragonfruit", "Fried Galunggong",
    "Fried Tilapia", "Ginataang Kalabasa", "Grapes", "Kiwi", "Lumpia",
    "Melon", "Monggo", "Nilagang Baka", "Orange", "Pancake",
    "Pancit", "Pandesal", "Papaya", "Pineapple", "Pork Adobo",
    "Pork Chop", "Rice", "Riped Mango", "Scrambled Egg", "Sunny Side Up",
    "Sweet Potato", "Togue", "Tortang Talong", "Watermelon", "Wheat Bread"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/screensbg.png',
              fit: BoxFit.cover,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Color(0xFF0E4A06), size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'About Us',
                      style: GoogleFonts.nunito(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0E4A06),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFF9FEED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFAAD3C4), width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NutriShow is a dietary assessment app that uses food image classification to estimate nutritional content and provide personalized guidance. It helps users track their intake of macronutrients and micronutrients based on their age, sex, height, weight, and activity level.',
                        style: GoogleFonts.nunito(fontSize: 16, color: Color(0xFF0E4A06), height: 1.5),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Recognizable Dishes:',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0E4A06),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: recognizableFoods.sublist(0, recognizableFoods.length ~/ 2).map((food) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    "• $food",
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Color(0xFF0E4A06),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: recognizableFoods.sublist(recognizableFoods.length ~/ 2).map((food) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    "• $food",
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: Color(0xFF0E4A06),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Divider(color: Color(0xFF0E4A06)),
                      Text(
                        'Developed by:',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0E4A06),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...[
                        "Batao, Bianca Louise F.",
                        "Locsin, Trisha Mae F",
                        "Mariano, Charimel C.",
                        "Molina, Gabriel S."
                      ].map((name) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          name,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            color: Color(0xFF0E4A06),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
