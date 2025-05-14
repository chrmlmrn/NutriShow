import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class FoodDiaryScreen extends StatefulWidget {
  final Map<String, dynamic> foodDetails;

  const FoodDiaryScreen({super.key, required this.foodDetails});

  @override
  _FoodDiaryScreenState createState() => _FoodDiaryScreenState();
}

class _FoodDiaryScreenState extends State<FoodDiaryScreen> {
  String _selectedMood = 'Neutral';
  double _satiety = 3.0;
  bool _isSubmitted = false;

  final List<Map<String, String>> moods = [
    {'emoji': '😄', 'label': 'Happy'},
    {'emoji': '😊', 'label': 'Satisfied'},
    {'emoji': '😐', 'label': 'Neutral'},
    {'emoji': '😕', 'label': 'Heavy'},
    {'emoji': '🤢', 'label': 'Sick'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDiaryData();
  }

  void _loadDiaryData() async {
    final prefs = await SharedPreferences.getInstance();
    final foodName = widget.foodDetails['food_name'] ?? 'unknown_food';
    final entryKey = 'diary_$foodName';

    final savedString = prefs.getString(entryKey);
    if (savedString != null) {
      final saved = jsonDecode(savedString);
      setState(() {
        _selectedMood = saved['mood'] ?? '';
        _satiety = (saved['satiety'] ?? 3.0).toDouble();
        _isSubmitted = saved['submitted'] ?? false;
      });
    }
  }

  void _submitEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final foodName = widget.foodDetails['food_name'] ?? 'unknown_food';
    final entryKey = 'diary_$foodName';

    final entryData = {
      'mood': _selectedMood,
      'satiety': _satiety,
      'submitted': true,
    };

    await prefs.setString(entryKey, jsonEncode(entryData));

    setState(() {
      _isSubmitted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🌟 Food diary entry saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = const Color(0xFF4CAF50);
    final Color pastelGreen = const Color(0xFFD3F1DF);
    final Color backgroundColor = const Color(0xFFFDFFF7);
    final Color chipColor = const Color(0xFFF4FFC3);

    return Scaffold(
      backgroundColor: Color(0xFFF9FEEB),
      appBar: AppBar(
        title: Text(
          'Food Diary',
          style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.w800, color: Color(0xFF0E4A06)),
        ),
        iconTheme: IconThemeData(color: Color(0xFF0E4A06), size: 30),
        backgroundColor: Color(0xFFF9FEEB),
        centerTitle: true,
        elevation: 0,
      ),
      body:
        Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/screensbg.png',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: pastelGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'How do you feel after eating?',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Wrap(
                              spacing: 30,
                              runSpacing: 16,
                              children: moods.map((mood) {
                                final isSelected = _selectedMood == mood['label'];
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: _isSubmitted
                                          ? null
                                          : () {
                                        setState(() {
                                          _selectedMood = mood['label']!;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? primaryGreen.withOpacity(0.2) : Colors.transparent,
                                          shape: BoxShape.circle,
                                          border: isSelected
                                              ? Border.all(color: primaryGreen, width: 2)
                                              : Border.all(color: Colors.grey.shade300, width: 1),
                                        ),
                                        child: Text(
                                          mood['emoji']!,
                                          style: TextStyle(
                                            fontSize: isSelected ? 36 : 30,
                                            color: isSelected ? primaryGreen : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      mood['label']!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color:
                                        isSelected ? primaryGreen : Colors.black87,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Satiety section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: pastelGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '💚 How full do you feel?',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap a number from 1 (Not full) to 5 (Very full).',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Wrap(
                              spacing: 14,
                              children: List.generate(5, (index) {
                                final displayNumber = index + 1; // 1 to 5
                                final isSelected = _satiety == displayNumber.toDouble();
                                return GestureDetector(
                                  onTap: _isSubmitted
                                      ? null
                                      : () {
                                    setState(() {
                                      _satiety = displayNumber.toDouble();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: isSelected ? primaryGreen.withOpacity(0.2) : chipColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected
                                          ? Border.all(color: primaryGreen, width: 2)
                                          : null,
                                    ),
                                    child: Text(
                                      displayNumber.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? primaryGreen : Colors.black87,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_selectedMood.isEmpty || _isSubmitted)
                            ? null
                            : _submitEntry,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save Entry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}