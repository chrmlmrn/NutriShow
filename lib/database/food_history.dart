import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FoodHistory {
  static const _key = 'food_history';

  static Future<void> addToHistory({
    required Map<String, dynamic> foodDetails,
    Map<String, dynamic>? assessment,
    Map<String, dynamic>? recommendedIntake,
    String? gender,
    String? portionSize,
    String? tip,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    Map<String, dynamic> fullEntry = {
      'foodDetails': foodDetails,
      'assessment': assessment,
      'recommendedIntake': recommendedIntake,
      'gender': gender,
      'portionSize': portionSize,
      'tip': tip, // <-- Add this line
    };

    history.insert(0, fullEntry);
    if (history.length > 5) history.removeLast();

    final encoded = jsonEncode(history);
    await prefs.setString(_key, encoded);
  }


  // Retrieve history
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_key);

    if (encoded == null) return [];

    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  // Clear history (optional)
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
