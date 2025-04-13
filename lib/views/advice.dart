import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrishow/views/user_input.dart';
import 'dart:math';

class MacronutrientAdvicePage extends StatelessWidget {
  final Map<String, dynamic> foodDetails;
  final Map<String, dynamic>? assessment;
  final Map<String, dynamic>? recommendedIntake;
  final List<String>? pinnedTips;
  final String? gender;
  final String? portionSize;
  final String? tip;
  final String? notice;
  final String activityLevel;


  const MacronutrientAdvicePage({
    super.key,
    required this.foodDetails,
    this.assessment,
    this.recommendedIntake,
    this.gender,
    this.portionSize,
    this.tip,
    this.notice,
    this.pinnedTips,
    required this.activityLevel,
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

  String? _getRecommendedKey(
    String nutrient, String gender, String activity, Map<String, dynamic> row) {
    final g = gender.toLowerCase().startsWith("m") ? "m" : "f";
    final a = activity.toLowerCase().contains("sedentary")
        ? "s"
        : activity.toLowerCase().contains("moderately active")
        ? "ma"
        : "a";

    final keys = [
      "${nutrient}_${g}_${a}_min",
      "${nutrient}_${g}_s_min",
      "${nutrient}_${g}_ma_min",
      "${nutrient}_${g}_a_min",
      "${nutrient}_${g}_min",
      "${nutrient}_min",
      "${nutrient}_${g}_${a}_max",
      "${nutrient}_${g}_s_max",
      "${nutrient}_${g}_ma_max",
      "${nutrient}_${g}_a_max",
      "${nutrient}_${g}_max",
      "${nutrient}_max",
      "${nutrient}_${g}_${a}",
      "${nutrient}_${g}",
      nutrient,
    ];

    return keys.firstWhere((k) => row[k] != null, orElse: () => '');
  }

  List<Widget> _buildPinnedAdvice() {
    final tooMuch = assessment?['too_much'] as List? ?? [];
    final lacking = assessment?['lacking'] as List? ?? [];
    final List<String> pins = [];
    final rand = Random();

    final proteinTooMuch = [
      "Your protein intake is too high—try cutting back a bit.",
      "Excess protein detected—moderation is advised.",
      "Consider limiting your protein intake as it exceeds recommendations.",
      "High protein levels found—consider lighter, low-protein food options.",
      "Protein intake is above the healthy limit—consume less for balance.",
    ];
    final carbsTooMuch = [
      "Carbohydrate levels are above ideal—moderate your consumption.",
      "Cut back on carbs to stay within recommended limits.",
      "Carbs are a bit too high—balance your meals accordingly.",
      "Consider eating fewer carbohydrates to stay within the healthy range.",
      "Your carbohydrate intake is too high—try to reduce it.",
    ];
    final fatsTooMuch = [
      "You’ve surpassed the healthy fat limit—adjust your consumption.",
      "You're going over the fat recommendation—reduce for a healthier balance.",
      "Fat intake should be moderated—consider choosing low-fat alternatives.",
      "You’ve gone past the ideal fat intake—scale it down to improve balance.",
      "Fat intake exceeded the recommended amount—moderate it accordingly.",
    ];
    final sodiumTooMuch = [
      "Excess sodium detected—try to cut back on processed or salty items.",
      "You’ve exceeded the recommended sodium levels—moderate your salt intake.",
      "Sodium levels are above the healthy limit—watch your salt intake.",
      "High sodium intake may lead to health risks—adjust your diet accordingly.",
      "You're consuming more sodium than needed—aim to reduce it."
    ];
    final fiberTooMuch = [
      "You’ve surpassed the healthy fat limit—adjust your consumption.",
      "You're going over the fat recommendation—reduce for a healthier balance.",
      "Fat intake should be moderated—consider choosing low-fat alternatives.",
      "You’ve gone past the ideal fat intake—scale it down to improve balance.",
      "Fat intake exceeded the recommended amount—moderate it accordingly."
    ];

    final proteinLack = [
      "Your protein intake is lower than recommended—try to include more in your diet.",
      "You're not getting enough protein—consider adding protein-rich foods.",
      "Consider boosting your protein intake to meet daily requirements.",
      "You may need more protein—add protein-rich meals or snacks.",
      "Not enough protein was found—try including more in your meals.",
    ];
    final carbsLack = [
      "You need more energy from carbs—consider adding more to your meals.",
      "Your current intake is low on carbs—consider increasing for sustained energy.",
      "You're consuming fewer carbs than needed—add more to your diet.",
      "Low carbohydrate levels detected—try increasing your intake.",
      "You're falling short on carbs—try balancing your meals better.",
    ];
    final fatsLack = [
      "Fat intake is too low—try including more in your meals.",
      "Low fat levels detected—consider boosting healthy fat intake.",
      "Fats are crucial and currently insufficient—add more nutritious fats.",
      "You're not meeting the daily fat requirement—eat more balanced fat sources.",
      "Try increasing your intake of healthy fats to improve overall nutrition.",
    ];
    final fiberLack = [
      "You may be missing out on enough fiber—consider adding more fiber-rich foods to your meals.",
      "Fiber intake is currently insufficient—boosting it may support better digestion.",
      "A bit more fiber in your diet could go a long way—start with small changes.",
      "Low fiber intake noticed—try to mix in high-fiber foods with your usual dishes.",
      "You're not quite hitting the fiber target—adjust your meals for better nutritional balance."
    ];

    if (tooMuch.any((e) => e.toLowerCase().contains("protein"))) {
      pins.add("\uD83D\uDCCC ${proteinTooMuch[rand.nextInt(5)]}");
    }
    if (tooMuch.any((e) => e.toLowerCase().contains("carbohydrate"))) {
      pins.add("\uD83D\uDCCC ${carbsTooMuch[rand.nextInt(5)]}");
    }
    if (tooMuch.any((e) => e.toLowerCase().contains("fat"))) {
      pins.add("\uD83D\uDCCC ${fatsTooMuch[rand.nextInt(5)]}");
    }
    if (tooMuch.any((e) => e.toLowerCase().contains("sodium"))) {
      pins.add("\uD83D\uDCCC ${sodiumTooMuch[rand.nextInt(5)]}");
    }
    if (tooMuch.any((e) => e.toLowerCase().contains("fiber"))) {
      pins.add("\uD83D\uDCCC ${fiberTooMuch[rand.nextInt(5)]}");
    }

    if (lacking.any((e) => e.toLowerCase().contains("protein"))) {
      pins.add("\uD83D\uDCCC ${proteinLack[rand.nextInt(5)]}");
    }
    if (lacking.any((e) => e.toLowerCase().contains("carbohydrate"))) {
      pins.add("\uD83D\uDCCC ${carbsLack[rand.nextInt(5)]}");
    }
    if (lacking.any((e) => e.toLowerCase().contains("fat"))) {
      pins.add("\uD83D\uDCCC ${fatsLack[rand.nextInt(5)]}");
    }
    if (lacking.any((e) => e.toLowerCase().contains("fiber"))) {
      pins.add("\uD83D\uDCCC ${fiberLack[rand.nextInt(5)]}");
    }


    return pins.map((msg) => Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        msg,
        style: GoogleFonts.nunito(
          fontSize: 16.5,
          fontStyle: FontStyle.italic,
          color: Color(0xFFcf2400),
        ),
      ),
    )).toList();
  }

  String _formatValue(num value) {
    if (portionSize != null) {
      if (portionSize!.contains('.') || portionSize!.contains('/')) {
        return value.toStringAsFixed(2);
      } else {
        final portionNumber = double.tryParse(portionSize!);
        if (portionNumber != null && portionNumber % 1 != 0) {
          return value.toStringAsFixed(2);
        }
      }
    }
    return value.toStringAsFixed(0); // Whole number if portion is whole
  }


  @override
  Widget build(BuildContext context) {
    print("Activity Level received: $activityLevel");

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
          style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w800, color: Color(0xFF0E4A06)),
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
                  fontSize: 25,
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
                    "$portionSize portion(s) • ${_calculateTotalGrams()} grams",
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              _buildNutritionFactsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderRow("🔥 Calories", "${_adjustForPortion(foodDetails['energy_kcal'] ?? 0).toStringAsFixed(0)} kcal"),
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
                    const SizedBox(height: 15),
                    if (notice != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          "ℹ️  $notice",
                          style: GoogleFonts.nunito(
                            fontSize: 15.5,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    const SizedBox(height: 5),

                    Text(
                      "Too much nutrients (${(assessment?['too_much'] as List?)?.length ?? 0}):",
                      style: GoogleFonts.nunito(fontSize: 16.5, fontWeight: FontWeight.w700),
                    ),
                    if ((assessment?['too_much'] as List?)?.isEmpty ?? true)
                      Text("⚫  None", style: GoogleFonts.nunito(fontSize: 16.5))
                    else
                      ...List.generate(
                        (assessment!['too_much'] as List).length,
                            (index) {
                          String item = assessment!['too_much'][index];

                          final matches = RegExp(r"(-?\d+(\.\d+)?)").allMatches(item).toList();

                          // If there are any numbers found in the string
                          if (matches.isNotEmpty) {
                            for (final match in matches) {
                              final original = match.group(0)!;
                              final parsed = double.tryParse(original);

                              if (parsed != null) {
                                final formatted = _formatValue(parsed);
                                item = item.replaceFirst(original, formatted);
                              }
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text("🔴  $item", style: GoogleFonts.nunito(fontSize: 16.5)),
                          );
                        },
                      ),

                    const SizedBox(height: 15),

                    Text(
                      "Lacking nutrients (${(assessment?['lacking'] as List?)?.length ?? 0}):",
                      style: GoogleFonts.nunito(fontSize: 16.5, fontWeight: FontWeight.w700),
                    ),
                    if ((assessment?['lacking'] as List?)?.isEmpty ?? true)
                      Text("⚫  None", style: GoogleFonts.nunito(fontSize: 16.5))
                    else
                      ...List.generate(
                        (assessment!['lacking'] as List).length,
                            (index) {
                          String item = assessment!['lacking'][index];

                          final matches = RegExp(r"(-?\d+(\.\d+)?)").allMatches(item).toList();

                          // If there are any numbers found in the string
                          if (matches.isNotEmpty) {
                            for (final match in matches) {
                              final original = match.group(0)!;
                              final parsed = double.tryParse(original);

                              if (parsed != null) {
                                final formatted = _formatValue(parsed);
                                item = item.replaceFirst(original, formatted);
                              }
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text("🟡  $item", style: GoogleFonts.nunito(fontSize: 16.5)),
                          );
                        },
                      ),

                    if (recommendedIntake != null)
                      ...[
                        const SizedBox(height: 15),
                        ...(pinnedTips?.map((msg) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            msg,
                            style: GoogleFonts.nunito(
                              fontSize: 16.5,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFFB80000),
                            ),
                          ),
                        )).toList() ?? _buildPinnedAdvice())
                      ]
                    else
                      Text("• Not available", style: GoogleFonts.nunito(fontSize: 16.5)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildRecommendedIntakeCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🍽️ Recommended Nutrient Intake per Day",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF206C15),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (recommendedIntake != null)
                      ...[
                        ..._buildRecommendedIntakeList(recommendedIntake!, activityLevel)
                      ]
                    else
                      Text("• Not available", style: GoogleFonts.nunito(fontSize: 16.5)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
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

  Widget _buildRecommendedIntakeCard({required Widget child, Color? color, Color borderColor = const Color(0xFF206C15)}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color(0XFFCAE0BC),
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
              "${(value != null) ? _formatValue(value as num) : 'Unknown'} $unit",
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
            style: GoogleFonts.nunito(fontSize: 16.5, fontStyle: FontStyle.italic),
          ),
          Text(
              "${(value != null) ? _formatValue(value as num) : 'Unknown'} $unit",
              style: GoogleFonts.nunito(fontSize: 16.5, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRecommendedIntakeList(Map<String, dynamic> intake, String activityLevel) {
    final isMale = gender?.toLowerCase().startsWith('m') ?? true;

    final raw = activityLevel.toLowerCase();
    final actCode = raw.contains('sedentary')
        ? 's'
        : raw.contains('moderately')
        ? 'ma'
        : 'a';

    final g = isMale ? 'm' : 'f';

    final nutrientsToShow = [
      ["energy", "Energy", "kcal"],
      ["protein", "Protein", "g"],
      ["carbohydrates", "Carbohydrates", "g"],
      ["fiber", "Fiber", "g"],
      ["total_sugars", "Total Sugars", "g"],
      ["total_fat", "Total Fat", "g"],
      ["sodium", "Sodium", "mg"],
      ["iron", "Iron", "mg"],
      ["zinc", "Zinc", "mg"],
      ["vitamin_c", "Vitamin C", "mg"],
      ["vitamin_b6", "Vitamin B6", "mg"],
      ["folate", "Folate", "μg"],
      ["vitamin_a", "Vitamin A", "μg"],
      ["vitamin_e", "Vitamin E", "mg"],
      ["vitamin_k", "Vitamin K", "μg"],
      ["calcium", "Calcium", "mg"],
      ["potassium", "Potassium", "mg"],
    ];

    List<Widget> output = [];

    for (final nutrient in nutrientsToShow) {
      final base = nutrient[0];
      final label = nutrient[1];
      final unit = nutrient[2];

      final minKeyCandidates = [
        "${base}_${g}_${actCode}_min",
        "${base}_${g}_s_min",
        "${base}_${g}_ma_min",
        "${base}_${g}_a_min",
        "${base}_${g}_min",
        "${base}_min",
      ];

      final maxKeyCandidates = [
        "${base}_${g}_${actCode}_max",
        "${base}_${g}_s_max",
        "${base}_${g}_ma_max",
        "${base}_${g}_a_max",
        "${base}_${g}_max",
        "${base}_max",
      ];

      final altKeyCandidates = [
        "${base}_${g}_${actCode}",
        "${base}_${g}_s",
        "${base}_${g}_ma",
        "${base}_${g}_a",
        "${base}_${g}",
        base,
      ];

      final minKey = minKeyCandidates.firstWhere((k) => intake.containsKey(k), orElse: () => '');
      final maxKey = maxKeyCandidates.firstWhere((k) => intake.containsKey(k), orElse: () => '');
      final altKey = altKeyCandidates.firstWhere((k) => intake.containsKey(k), orElse: () => '');

      final minVal = minKey.isNotEmpty ? intake[minKey] : null;
      final maxVal = maxKey.isNotEmpty ? intake[maxKey] : null;

      String displayText;
      if (minVal != null && maxVal != null) {
        displayText = "${_formatValue(minVal)}–${_formatValue(maxVal)} $unit";
      } else if (minVal != null) {
        displayText = "≥ ${_formatValue(minVal)} $unit";
      } else if (maxVal != null) {
        displayText = "≤ ${_formatValue(maxVal)} $unit";
      } else if (altKey.isNotEmpty && intake[altKey] != null) {
        displayText = "${_formatValue(intake[altKey])} $unit";
      } else {
        continue;
      }

      output.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            "🟢  $label: $displayText",
            style: GoogleFonts.nunito(fontSize: 16.5),
          ),
        ),
      );
    }

    return output;
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

    double totalGrams = baseServing * multiplier;

    // Format based on portion format
    bool showDecimal = false;
    if (portionSize != null) {
      if (portionSize!.contains(".") || portionSize!.contains("/")) {
        showDecimal = true;
      } else {
        final parsed = double.tryParse(portionSize!);
        if (parsed != null && parsed % 1 != 0) {
          showDecimal = true;
        }
      }
    }

    return showDecimal ? totalGrams.toStringAsFixed(2) : totalGrams.toStringAsFixed(0);
  }

}
