import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String dbPath = join(await getDatabasesPath(), 'nutrishow_db.db');

    bool dbExists = await databaseExists(dbPath);
    if (dbExists) {
      print("Deleting old database...");
      await deleteDatabase(dbPath);
    }

    print("Copying new database from assets...");
    ByteData data = await rootBundle.load('assets/nutrishow_db.db');
    List<int> bytes = data.buffer.asUint8List();
    await File(dbPath).writeAsBytes(bytes, flush: true);

    print("Database copied successfully.");
    return await openDatabase(dbPath);
  }

  Future<Map<String, dynamic>?> getFoodDetails(String foodName) async {
    final db = await database;

    List<Map<String, dynamic>> allServings = await db.rawQuery("SELECT * FROM food_servings");
    print("All Food Servings in Flutter: $allServings");

    List<Map<String, dynamic>> results = await db.rawQuery(
        '''
    SELECT fi.food_name, fs.*
    FROM food_items fi
    JOIN food_servings fs ON fi.food_uid = fs.food_uid
    WHERE LOWER(fi.food_name) = ?
    ''',
        [foodName.trim().toLowerCase()]
    );

    print("Query Results: $results");

    return results.isNotEmpty ? results.first : null;
  }
}

