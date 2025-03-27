import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FoodHistory {
  static const _key = 'food_history';

  // Save food details to history
  static Future<void> addToHistory(Map<String, dynamic> foodDetails) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();

    history.insert(0, foodDetails);

    if (history.length > 5) {
      history.removeLast();
    }

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
