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
      SELECT fi.food_name, fs.*
      FROM food_items fi
      JOIN food_servings fs ON fi.food_uid = fs.food_uid
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

  // Assess the diet based on food data and recommended intake
  Map<String, dynamic> assessDiet({
    required Map<String, dynamic> foodData,
    required Map<String, dynamic> recommendedRow,
    required String gender,
    required String activity,
  }) {
    String g = gender.toLowerCase().startsWith("m") ? "m" : "f";
    String a = activity.toLowerCase().contains("sedentary")
        ? "s"
        : activity.toLowerCase().contains("moderately")
        ? "ma"
        : "a";

    final nutrients = {
      "Energy": ["energy_kcal", "energy_${g}_$a", "kcal"],
      "Protein": ["protein_g", "protein_$g", "g"],
      "Carbohydrates": ["carbohydrates_g", "carbohydrates_${g}_${a}_min", "g"],
      "Fiber": ["fiber_g", "fiber_min", "g"],
      "Total Sugars": ["total_sugars_g", "total_sugars_${g}_$a", "g"],
      "Total Fat": ["total_fat_g", "total_fat_${g}_${a}_max", "g"],
      "Sodium": ["sodium_mg", "sodium", "mg"],
      "Iron": ["iron_mg", "iron_$g", "mg"],
      "Zinc": ["zinc_mg", "zinc_$g", "mg"],
      "Vitamin C": ["vitamin_c_mg", "vitamin_c_$g", "mg"],
      "Vitamin B6": ["vitamin_b6_mg", "vitamin_b6_$g", "mg"],
      "Folate": ["folate_ug", "folate_$g", "mcg"],
      "Vitamin A": ["vitamin_a_ug", "vitamin_a_$g", "mcg"],
      "Vitamin E": ["vitamin_e_mg", "vitamin_e_$g", "mg"],
      "Vitamin K": ["vitamin_k_ug", "vitamin_k_$g", "mcg"],
      "Calcium": ["calcium_mg", "calcium_$g", "mg"],
      "Potassium": ["potassium_mg", "potassium", "mg"],
    };

    List<String> lacking = [];
    List<String> tooMuch = [];

    nutrients.forEach((label, cols) {
      String foodKey = cols[0];
      String recKey = cols[1];
      String unit = cols[2];

      double foodVal = double.tryParse("${foodData[foodKey]}".replaceAll("<", "").trim()) ?? 0;
      double recVal = double.tryParse("${recommendedRow[recKey]}".replaceAll("<", "").trim()) ?? 0;

      if (recVal <= 0) return;

      double diff = foodVal - recVal;

      if (diff < -0.3 * recVal) {
        lacking.add("$label (−${diff.abs().toStringAsFixed(1)}$unit)");
      } else if (diff > 0.3 * recVal) {
        tooMuch.add("$label (+${diff.toStringAsFixed(1)}$unit)");
      }
    });

    return {
      "lacking": lacking,
      "too_much": tooMuch,
    };
  }

  Future<String> queryPortionType(String foodId) async {
    final db = await database;

    // Query the portion type for the foodId (e.g., 'nf_001')
    var result = await db.rawQuery(
      '''
    SELECT portion
    FROM food_servings
    WHERE food_uid = ?
    ''',
      [foodId],
    );

    // Debug: Print the result of the query
    print("Query result for foodId ($foodId): $result");

    // Check if the result is not empty and return the portion
    if (result.isNotEmpty && result.first['portion'] != null) {
      return result.first['portion'] as String;
    } else {
      throw Exception("Portion not found for food ID: $foodId");
    }
  }



}

extension StringExtension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
