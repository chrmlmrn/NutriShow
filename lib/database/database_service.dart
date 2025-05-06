import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  // Database initialization and connection
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialize the database from assets
  Future<Database> _initDB() async {
    String dbPath = join(await getDatabasesPath(), 'nutrishow_data.db');

    bool dbExists = await databaseExists(dbPath);
    if (dbExists) {
      print("Deleting old database...");
      await deleteDatabase(dbPath);
    }

    print("Copying new database from assets...");
    ByteData data = await rootBundle.load('assets/nutrishow_data.db');
    List<int> bytes = data.buffer.asUint8List();
    await File(dbPath).writeAsBytes(bytes, flush: true);

    print("Database copied successfully.");
    return await openDatabase(dbPath);
  }

  // Get food details for a given food name
  Future<Map<String, dynamic>?> getFoodDetails(String foodName) async {
    final db = await database;

    // Query to get all food servings (for debugging purposes)
    List<Map<String, dynamic>> allServings = await db.rawQuery("SELECT * FROM food_servings");
    print("All Food Servings in Flutter: $allServings");

    // Query to join food_items and food_servings to get details for the provided food name
    List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      SELECT fi.food_name, fc.category_name, fs.*
      FROM food_items fi
      JOIN food_servings fs ON fi.food_uid = fs.food_uid
      JOIN food_category fc ON fi.category_uid = fc.category_uid
      WHERE LOWER(fi.food_name) = ?
      ''',
      [foodName.trim().toLowerCase()],
    );

    print("Query Results: $results");

    // Return the first result or null if no results found
    return results.isNotEmpty ? results.first : null;
  }

  // Get recommended nutrient intake for a specific age
  Future<Map<String, dynamic>> getRecommendedIntakeRow(int age) async {
    final db = await database;
    final result = await db.query('user_recommended_nutrient_intake', where: 'age = ?', whereArgs: [age]);
    return result.isNotEmpty ? result.first : {};
  }

  Map<String, dynamic> assessDiet({
    required Map<String, dynamic> foodData,
    required Map<String, dynamic> recommendedRow,
    required String gender,
    required String activity,
    String? portionSize,
  }) {
    String g = gender.toLowerCase().startsWith("m") ? "m" : "f";
    String a = activity.toLowerCase().contains("sedentary")
        ? "s"
        : activity.toLowerCase().contains("moderate")
        ? "ma"
        : "a";

    final nutrients = {
      "Energy": ["energy_kcal", "energy", "kcal"],
      "Protein": ["protein_g", "protein", "g"],
      "Carbohydrates": ["carbohydrates_g", "carbohydrates", "g"],
      "Fiber": ["fiber_g", "fiber", "g"],
      "Total Sugars": ["total_sugars_g", "total_sugars", "g"],
      "Total Fat": ["total_fat_g", "total_fat", "g"],
      "Sodium": ["sodium_mg", "sodium", "mg"],
      "Iron": ["iron_mg", "iron", "mg"],
      "Zinc": ["zinc_mg", "zinc", "mg"],
      "Vitamin C": ["vitamin_c_mg", "vitamin_c", "mg"],
      "Vitamin B6": ["vitamin_b6_mg", "vitamin_b6", "mg"],
      "Folate": ["folate_ug", "folate", "mcg"],
      "Vitamin A": ["vitamin_a_ug", "vitamin_a", "μg"],
      "Vitamin E": ["vitamin_e_mg", "vitamin_e", "mg"],
      "Vitamin K": ["vitamin_k_ug", "vitamin_k", "μg"],
      "Calcium": ["calcium_mg", "calcium", "mg"],
      "Potassium": ["potassium_mg", "potassium", "mg"],
    };

    double multiplier = 1.0;
    if (portionSize != null && portionSize.isNotEmpty) {
      if (portionSize.contains("/")) {
        final parts = portionSize.split("/");
        if (parts.length == 2) {
          final numerator = double.tryParse(parts[0]) ?? 1;
          final denominator = double.tryParse(parts[1]) ?? 1;
          multiplier = numerator / denominator;
        }
      } else {
        multiplier = double.tryParse(portionSize) ?? 1;
      }
    }

    List<String> lacking = [];
    List<String> tooMuch = [];

    nutrients.forEach((label, values) {
      final foodKey = values[0];
      final baseKey = values[1];
      final unit = values[2];

      double foodVal = double.tryParse("${foodData[foodKey]}".replaceAll("<", "").trim()) ?? 0;
      foodVal *= multiplier;

      String? minKey = [
        "${baseKey}_${g}_${a}_min",
        "${baseKey}_${g}_s_min",
        "${baseKey}_${g}_ma_min",
        "${baseKey}_${g}_a_min",
        "${baseKey}_${g}_min",
        "${baseKey}_min"
      ].firstWhere((k) => recommendedRow[k] != null, orElse: () => "");

      String? maxKey = [
        "${baseKey}_${g}_${a}_max",
        "${baseKey}_${g}_s_max",
        "${baseKey}_${g}_ma_max",
        "${baseKey}_${g}_a_max",
        "${baseKey}_${g}_max",
        "${baseKey}_max"
      ].firstWhere((k) => recommendedRow[k] != null, orElse: () => "");


      if (minKey.isNotEmpty && maxKey.isNotEmpty) {
        double minVal = double.tryParse("${recommendedRow[minKey]}".replaceAll("<", "")) ?? 0;
        double maxVal = double.tryParse("${recommendedRow[maxKey]}".replaceAll("<", "")) ?? 0;
        if (foodVal < minVal) {
          lacking.add("$label (−${(minVal - foodVal).toStringAsFixed(1)}$unit)");
        } else if (foodVal > maxVal) {
          tooMuch.add("$label (+${(foodVal - maxVal).toStringAsFixed(1)}$unit)");
        }
      } else {
        String? singleKey = [
          "${baseKey}_${g}_${a}",
          "${baseKey}_${g}_s",
          "${baseKey}_${g}_ma",
          "${baseKey}_${g}_a",
          "${baseKey}_${g}",
          baseKey
        ].firstWhere((k) => recommendedRow[k] != null, orElse: () => "");
        if (singleKey.isNotEmpty) {
          double recVal = double.tryParse("${recommendedRow[singleKey]}".replaceAll("<", "")) ?? 0;
          if (recVal > 0) {
            double diff = foodVal - recVal;
            if (diff < -0.3 * recVal) {
              lacking.add("$label (−${diff.abs().toStringAsFixed(1)}$unit)");
            } else if (diff > 0.3 * recVal) {
              tooMuch.add("$label (+${diff.toStringAsFixed(1)}$unit)");
            }
          }
        }
      }
    });

    return {
      "lacking": lacking,
      "too_much": tooMuch,
    };
  }

  Future<String> queryPortionType(String foodId) async {
    final db = await database;

    var result = await db.rawQuery(
      '''
      SELECT portion
      FROM food_servings
      WHERE food_uid = ?
      ''',
      [foodId],
    );

    print("Query result for foodId (\$foodId): \$result");

    if (result.isNotEmpty && result.first['portion'] != null) {
      return result.first['portion'] as String;
    } else {
      throw Exception("Portion not found for food ID: \$foodId");
    }
  }

}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
