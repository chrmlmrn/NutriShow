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
    "10 to 12 years",
    "13 to 15 years",
    "16 to 18 years",
    "19 to 29 years",
    "30 to 49 years",
  ];

  final List<String> _genders = ["Male", "Female"];
  final List<String> _activityLevels = [
    "Sedentary - Little to no physical activity, mostly sitting or lying down.",
    "Lightly Active - Light exercise 1-3 days per week, such as casual walking or stretching.",
    "Active - Moderate exercise 3-5 days per week, such as jogging, cycling, or gym workouts.",
    "Very Active - Intense physical activity 6-7 days per week, including sports and strength training."
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
                      onPressed: () => setState(() => _isKg = true),
                      child: const Text("kg"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isKg ? Colors.grey : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isKg = false),
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
                      onPressed: () => setState(() => _isCm = true),
                      child: const Text("cm"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCm ? Colors.grey : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isCm = false),
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
                items: _activityLevels
                    .map((level) => DropdownMenuItem(
                  value: level,
                  child: Text(level),
                ))
                    .toList(),
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
