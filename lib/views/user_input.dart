import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrishow/views/about_us.dart';
import 'options.dart';

class UserInputView extends StatelessWidget {
  const UserInputView({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UserInputScreen(),
    );
  }
}

class UserInputScreen extends StatefulWidget {
  const UserInputScreen({super.key});

  @override
  _UserInputScreenState createState() => _UserInputScreenState();
}

class _UserInputScreenState extends State<UserInputScreen> {
  final _ageController = TextEditingController();
  String? _selectedGender;
  String? _selectedActivityLevel;
  final _heightCmController = TextEditingController();
  final _heightFeetController = TextEditingController();
  final _heightInchesController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isCm = true;
  bool _isKg = true;

  final List<String> _genders = ["Male", "Female"];

  final Map<String, String> _activityLevelsWithDescriptions = {
    "Sedentary": "Light physical activity involved with everyday living",
    "Moderately Active": "Physical activities equal to walking about 1.5 to 3 miles per day at 3 to 4 miles per hour, in addition to the light activities of daily living",
    "Active": "Physical activities equal to walking more than 3 miles per day at 3 to 4 miles per hour, in addition to the light activities of daily living",
  };

  void _convertWeight() {
    if (_weightController.text.isNotEmpty) {
      double weight = double.tryParse(_weightController.text) ?? 0;
      if (_isKg) {
        _weightController.text = (weight / 2.20462).toStringAsFixed(2);
      } else {
        _weightController.text = (weight * 2.20462).toStringAsFixed(2);
      }
    }
  }

  void _convertHeight() {
    if (_isCm) {
      if (_heightFeetController.text.isNotEmpty || _heightInchesController.text.isNotEmpty) {
        int feet = int.tryParse(_heightFeetController.text) ?? 0;
        int inches = int.tryParse(_heightInchesController.text) ?? 0;
        double totalInches = (feet * 12).toDouble() + inches; // Explicit conversion
        double cm = totalInches * 2.54;
        _heightCmController.text = cm.toStringAsFixed(2);
      }
    } else {
      if (_heightCmController.text.isNotEmpty) {
        double cm = double.tryParse(_heightCmController.text) ?? 0;
        double totalInches = cm / 2.54;
        int feet = (totalInches ~/ 12);
        int inches = (totalInches % 12).toInt();
        _heightFeetController.text = feet.toString();
        _heightInchesController.text = inches.toString();
      }
    }
  }

  void _toggleWeightUnit(int index) {
    setState(() {
      _isKg = index == 0;
      _convertWeight();
    });
  }

  void _toggleHeightUnit(int index) {
    setState(() {
      _isCm = index == 0;
      _convertHeight();
    });
  }

  void _submitData() {
    final weightText = _weightController.text;
    double? heightCm;

    if (_isCm) {
      heightCm = double.tryParse(_heightCmController.text);
    } else {
      int feet = int.tryParse(_heightFeetController.text) ?? 0;
      int inches = int.tryParse(_heightInchesController.text) ?? 0;
      double totalInches = ((feet * 12) + inches).toDouble(); // Fixed!
      heightCm = totalInches * 2.54;
    }

    if (_ageController.text.isNotEmpty &&
        _selectedGender != null &&
        _selectedActivityLevel != null &&
        heightCm != null &&
        weightText.isNotEmpty) {

      double weightKg = _isKg
          ? double.tryParse(weightText) ?? 0
          : (double.tryParse(weightText) ?? 0) / 2.20462;

      double heightMeters = heightCm / 100;

      if (heightMeters <= 0 || weightKg <= 0) {
        _showErrorDialog("Invalid height or weight values.");
        return;
      }

      double bmi = weightKg / (heightMeters * heightMeters);
      String category;

      if (bmi < 18.5) {
        category = "Underweight";
      } else if (bmi < 25) {
        category = "Healthy Weight";
      } else if (bmi < 30) {
        category = "Overweight";
      } else {
        category = "Obese";
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFFCFE3DA),
          title: Text("BMI Status", style: GoogleFonts.poppins(fontSize: 25, color: Color(0xFF0E4A06), fontWeight: FontWeight.w700)),
          content: Text(
            category == "Healthy Weight"
                ? "You're doing well! A BMI of ${bmi.toStringAsFixed(2)} puts you in the \"Healthy Weight\" category. Keep it up!"
                : "Your BMI is ${bmi.toStringAsFixed(2)}. You are in the \"$category\" range. We advice that you seek the expertise of a Registered Nutritionist-Dietitian to get a personalized patient-centered nutrition consultation and dietary plan. \n\nNote: You may still use the app and view nutritional content, but dietary assessment will be disabled.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DishOptionsScreen(
                      age: int.parse(_ageController.text),
                      gender: _selectedGender!,
                      activityLevel: _selectedActivityLevel!,
                      bmiCategory: category,
                    ),
                  ),
                );
              },
              child: Text("Continue", style: GoogleFonts.poppins(fontSize: 15, color: Color(0xFF0E4A06), fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    } else {
      _showErrorDialog("Please fill in all the fields to proceed.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFFCFE3DA),
        title: Text("Notice", style: GoogleFonts.poppins(fontSize: 25, color: Color(0xFF0E4A06), fontWeight:FontWeight.w700)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK", style: GoogleFonts.poppins(fontSize: 15, color: Color(0xFF0E4A06), fontWeight:FontWeight.w700)),
          ),
        ],
      ),
    );
  }

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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/logo.png',
                          height: 70,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          'NutriShow',
                          style: GoogleFonts.changaOne(
                            fontSize: 50,
                            color: Color(0xFF0E4A06),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.info_outline, color: Color(0xFF0E4A06), size: 30),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutUsScreen(), // Make sure this screen exists
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Text(
                  'User Metrics',
                  style: GoogleFonts.nunito(
                    fontSize: 34.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0E4A06),
                  ),
                ),
                const SizedBox(height: 35),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number, // Allows only numeric input
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF9FEED),
                    labelText: 'Age',
                    labelStyle: GoogleFonts.nunito(color: Color(0xFF0E4A06)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0xFFAAD3C4), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0xFF809D3C), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: _genders
                      .map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF9FEED),
                    labelText: 'Sex',
                    labelStyle: GoogleFonts.nunito(color: Color(0xFF0E4A06)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0xFFAAD3C4), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0xFF809D3C), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF9FEED),
                          labelText: _isKg ? 'Weight (kg)' : 'Weight (lbs)',
                          labelStyle: GoogleFonts.nunito(color: Color(0xFF0E4A06)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Color(0xFFAAD3C4), width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Color(0xFF809D3C), width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ToggleButtons(
                      isSelected: [_isKg, !_isKg],
                      onPressed: _toggleWeightUnit,
                      borderRadius: BorderRadius.circular(5), // Makes it rounder
                      selectedBorderColor: Color(0xFF0E4A06), // Border color when selected
                      borderColor: Color(0xFFAAD3C4), // Border color when unselected
                      fillColor: Color(0xFFABCB4D), // Background color when selected
                      selectedColor: Color(0xFF0E4A06), // Text color when selected
                      color: Colors.black, // Text color when unselected
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text("kg"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text("lbs"),
                        ),
                      ],

                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _isCm
                          ? TextField(
                        controller: _heightCmController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFFF9FEED),
                          labelText: 'Height (cm)',
                          labelStyle: GoogleFonts.nunito(color: Color(0xFF0E4A06)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Color(0xFFAAD3C4), width: 2), // Unfocused border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: Color(0xFF809D3C), width: 2), // Border when focused
                          ),
                        ),
                      )
                          : Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _heightFeetController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFFF9FEED),
                                labelText: 'Feet',
                                labelStyle: GoogleFonts.nunito(color: Color(0xFF0E4A06)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(color: Color(0xFFAAD3C4), width: 2), // Unfocused border
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(color: Color(0xFF809D3C), width: 2), // Border when focused
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _heightInchesController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Color(0xFFF9FEED),
                                labelText: 'Inches',
                                labelStyle: GoogleFonts.nunito(color: Color(0xFF0E4A06)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(color: Color(0xFFAAD3C4), width: 2), // Unfocused border
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(color: Color(0xFF809D3C), width: 2), // Border when focused
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ToggleButtons(
                      isSelected: [_isCm, !_isCm],
                      onPressed: _toggleHeightUnit,
                      borderRadius: BorderRadius.circular(5), // Makes it rounder
                      selectedBorderColor: Color(0xFF0E4A06), // Border color when selected
                      borderColor: Color(0xFFAAD3C4), // Border color when unselected
                      fillColor: Color(0xFFABCB4D), // Background color when selected
                      selectedColor: Color(0xFF0E4A06), // Text color when selected
                      color: Colors.black, // Text color when unselected
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text("cm"),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text("ft/in"),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                DropdownButtonFormField<String>(
                  value: _selectedActivityLevel,
                  isExpanded: true,
                  menuMaxHeight: 300,
                  items: _activityLevelsWithDescriptions.entries.map((entry) {
                    return DropdownMenuItem(
                      value: entry.key,
                      child: ListTile(
                        title: Text(entry.key), // Show only the title in the dropdown list
                        subtitle: Text(entry.value), // Show subtitle inside the dropdown
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedActivityLevel = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFF9FEED),
                    labelText: 'Activity Level',
                    labelStyle: GoogleFonts.nunito(color: Color(0xFF0E4A06)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0xFFAAD3C4), width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: const BorderSide(color: Color(0xFF809D3C), width: 2),
                    ),
                  ),
                  selectedItemBuilder: (context) => _activityLevelsWithDescriptions.keys.map((title) {
                    return Text(
                      title, // Only display the main title in the dropdown button (prevents overflow)
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 14),
                      backgroundColor: Color(0xFF5D8736),
                      foregroundColor: Color(0xFFF4FFC3),
                    ),
                    child: Text(
                      "Submit",
                      style: GoogleFonts.nunito(fontSize: 16.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}
