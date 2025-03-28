import 'package:flutter/material.dart';
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
  String? _selectedAgeGroup;
  String? _selectedGender;
  String? _selectedActivityLevel;
  final _heightCmController = TextEditingController();
  final _heightFeetController = TextEditingController();
  final _heightInchesController = TextEditingController();
  final _weightController = TextEditingController();
  bool _isCm = true;
  bool _isKg = true;

  final List<String> _ageGroups = [
    "1 to 5 months old",
    "6 to 11 months old",
    "1 to 2 years old",
    "3 to 5 years old",
    "6 to 9 years old",
    "10 to 12 years old",
    "13 to 15 years old",
    "16 to 18 years old",
    "19 to 29 years old",
    "30 to 49 years old",
    "50 to 59 years old",
    "60 to 69 years old",
    "70 to 75 years old",
    "75 years old above",
  ];

  final List<String> _genders = ["Male", "Female"];
  final List<String> _activityLevels = [
    "Less than 30 min/day of moderate activity",
    "30 to 60 min/day of moderate activity",
    "More than 60 min/day of moderate activity",
  ];

  void _submitData() {
    final heightText = _isCm ? _heightCmController.text : _heightFeetController.text;
    final weightText = _weightController.text;

    if (_selectedAgeGroup != null &&
        _selectedGender != null &&
        _selectedActivityLevel != null &&
        heightText.isNotEmpty &&
        weightText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DishOptionsScreen()),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Input Required"),
          content: const Text("Please fill in all the fields to proceed."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _convertCmToFeetInches() {
    final cmText = _heightCmController.text;
    if (cmText.isNotEmpty) {
      final cm = double.tryParse(cmText);
      if (cm != null) {
        final totalInches = cm / 2.54;
        final feet = totalInches ~/ 12;
        final inches = (totalInches % 12).round();
        _heightFeetController.text = feet.toString();
        _heightInchesController.text = inches.toString();
      }
    }
  }

  void _convertFeetInchesToCm() {
    final feetText = _heightFeetController.text;
    final inchesText = _heightInchesController.text;
    final feet = double.tryParse(feetText) ?? 0;
    final inches = double.tryParse(inchesText) ?? 0;
    final cm = (feet * 12 + inches) * 2.54;
    _heightCmController.text = cm.round().toString();
  }

  void _convertKgToLbs() {
    final kgText = _weightController.text;
    if (kgText.isNotEmpty) {
      final kg = double.tryParse(kgText);
      if (kg != null) {
        final lbs = (kg * 2.20462).round();
        _weightController.text = lbs.toString();
      }
    }
  }

  void _convertLbsToKg() {
    final lbsText = _weightController.text;
    if (lbsText.isNotEmpty) {
      final lbs = double.tryParse(lbsText);
      if (lbs != null) {
        final kg = (lbs / 2.20462).round();
        _weightController.text = kg.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Enter Your Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedAgeGroup,
                items: _ageGroups
                    .map((ageGroup) => DropdownMenuItem(
                  value: ageGroup,
                  child: Text(ageGroup),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAgeGroup = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
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
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              const Text("Weight", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (!_isKg) _convertLbsToKg();
                          _isKg = true;
                        });
                      },
                      child: const Text("kg"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isKg ? Colors.grey : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_isKg) _convertKgToLbs();
                          _isKg = false;
                        });
                      },
                      child: const Text("lbs"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isKg ? Colors.grey : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _isKg ? 'Weight (kg)' : 'Weight (lbs)',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              const Text("Height", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _convertFeetInchesToCm();
                          _isCm = true;
                        });
                      },
                      child: const Text("cm"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCm ? Colors.grey : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _convertCmToFeetInches();
                          _isCm = false;
                        });
                      },
                      child: const Text("ft/in"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isCm ? Colors.grey : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _isCm
                  ? TextField(
                controller: _heightCmController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
              )
                  : Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heightFeetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Feet',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _heightInchesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Inches',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedActivityLevel,
                isExpanded: true,
                menuMaxHeight: 300,
                items: _activityLevels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        level,
                        softWrap: true,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedActivityLevel = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Activity Level',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitData,
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
