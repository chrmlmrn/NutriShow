// import 'package:flutter/material.dart';
// import 'package:nutrishow/database/database_service.dart';
// import 'package:sqflite/sqflite.dart';
//
// class FoodList extends StatefulWidget {
//   @override
//   _FoodListState createState() => _FoodListState();
// }
//
// class _FoodListState extends State<FoodList> {
//   late Database _db;
//   List<Map<String, dynamic>> _foodItems = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeDatabase();
//   }
//
//   Future<void> _initializeDatabase() async {
//     _db = await openDatabaseConnection();
//     _loadFoodItems();
//   }
//
//   Future<void> _loadFoodItems() async {
//     try {
//       List<Map<String, dynamic>> items = await getFoodItems(_db);
//       print('Fetched items: $items'); // Debug log
//       setState(() {
//         _foodItems = items;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading data: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: Text('Food List')),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: Text('Food List')),
//       body: _foodItems.isEmpty
//           ? Center(child: Text('No data found.'))
//           : ListView.builder(
//         itemCount: _foodItems.length,
//         itemBuilder: (context, index) {
//           final food = _foodItems[index];
//           return ListTile(
//             title: Text(food['food_name'] ?? 'Unknown Food'), // Updated key
//             subtitle: Text('Category: ${food['category_uid'] ?? 'Unknown'}'), // Updated key
//           );
//         },
//       ),
//     );
//   }
// }
