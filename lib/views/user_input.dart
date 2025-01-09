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
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedGender;
  String? _selectedActivityLevel;

  final List<String> _genders = ["Male", "Female"];
  final List<String> _activityLevels = [
    "Sedentary",
    "Lightly Active",
    "Active",
    "Very Active"
  ];

  // Method to validate and navigate
  void _submitData() {
    final ageText = _ageController.text;
    final heightText = _heightController.text;
    final weightText = _weightController.text;

    if (ageText.isNotEmpty &&
        heightText.isNotEmpty &&
        weightText.isNotEmpty &&
        _selectedGender != null &&
        _selectedActivityLevel != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DishOptionsScreen()),
      );
    } else {
      // Show an alert if any field is empty
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Input Required"),
          content: const Text(
              "Please fill in all the fields to proceed."),
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
            children: <Widget>[
              const Text(
                'Enter Your Details',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
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
              ElevatedButton(
                onPressed: _submitData,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
