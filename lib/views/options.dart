import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrishow/database/database_service.dart';
import 'package:nutrishow/database/food_history.dart';
import 'package:nutrishow/views/advice.dart';
import 'package:nutrishow/views/history.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;

class DishOptionsScreen extends StatefulWidget {
  const DishOptionsScreen({super.key});

  @override
  _DishOptionsScreenState createState() => _DishOptionsScreenState();
}

class _DishOptionsScreenState extends State<DishOptionsScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _foodResult;
  late Interpreter _foodInterpreter;
  late List<String> _labels;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    _foodInterpreter = await Interpreter.fromAsset('assets/mobilenetv2_food_classifier.tflite');
    _labels = await _loadLabels('assets/labels.txt');
  }

  Future<List<String>> _loadLabels(String path) async {
    final labels = await DefaultAssetBundle.of(context).loadString(path);
    return labels.split('\n');
  }

  Future<List<List<List<List<double>>>>?> _preprocessImage(File imageFile) async {
    final rawImage = await imageFile.readAsBytes();
    final image = img.decodeImage(Uint8List.fromList(rawImage));

    if (image == null) {
      throw Exception("Failed to decode image.");
    }

    final resizedImage = img.copyResize(image, width: 224, height: 224);

    final inputTensor = [
      List.generate(224, (y) {
        return List.generate(224, (x) {
          final pixel = resizedImage.getPixelSafe(x, y);
          final r = pixel.r / 127.5 - 1.0;
          final g = pixel.g / 127.5 - 1.0;
          final b = pixel.b / 127.5 - 1.0;
          return [r, g, b];
        });
      })
    ];

    return inputTensor;
  }

  Future<void> _runDetection() async {
    if (_image == null) return;

    try {
      final input = await _preprocessImage(File(_image!.path));
      if (input == null) {
        throw Exception("Failed to preprocess image.");
      }

      final foodOutput = List.filled(80, 0.0).reshape([1, 80]);
      _foodInterpreter.run(input, foodOutput);

      final predictions = foodOutput[0]
          .asMap()
          .entries
          .map((entry) => {'label': _labels[entry.key], 'confidence': entry.value})
          .toList()
        ..sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));

      setState(() {
        _foodResult = '${predictions[0]["label"]} (${(predictions[0]["confidence"] * 100).toStringAsFixed(2)}%)';
      });
    } catch (e) {
      print("Error during inference: $e");
      setState(() {
        _foodResult = "Error during inference.";
      });
    }
  }

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = photo;
        _foodResult = null;
      });
      await _runDetection();
    }
  }

  Future<void> _uploadDish() async {
    final photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() {
        _image = photo;
        _foodResult = null;
      });
      await _runDetection();
    }
  }


  Future<void> _getAdvice() async {
    if (_foodResult == null) return;

    String foodName = _foodResult!.split(" (")[0].trim();
    print("Predicted Food Name: $foodName");

    DatabaseHelper dbHelper = DatabaseHelper();
    Map<String, dynamic>? foodDetails = await dbHelper.getFoodDetails(foodName);

    if (foodDetails != null) {
      // TODO: Replace with actual user input values
      int userAge = 25; // <-- You should get this from user input screen
      String userGender = "Male"; // or "Female"
      String userActivity = "Moderately Active"; // match the dropdown string

      Map<String, dynamic> recommendedRow = await dbHelper.getRecommendedIntakeRow(userAge);

      Map<String, dynamic> assessment = dbHelper.assessDiet(
        foodData: foodDetails,
        recommendedRow: recommendedRow,
        gender: userGender,
        activity: userActivity,
      );

      print("Lacking nutrients (${assessment['lacking'].length}): ${assessment['lacking']}");
      print("Too much nutrients (${assessment['too_much'].length}): ${assessment['too_much']}");



      await FoodHistory.addToHistory(foodDetails);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MacronutrientAdvicePage(
            foodDetails: foodDetails,
            assessment: assessment,
            recommendedIntake: recommendedRow,
            gender: userGender,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No nutritional data found for '$foodName'")),
      );
    }
  }


  @override
  void dispose() {
    _foodInterpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FEEB),
      appBar: AppBar(
        backgroundColor: Color(0xFFF9FEEB),
        iconTheme: IconThemeData(
          color: Color(0xFF0E4A06),
          size: 30,
        ),
        title:
          Center(
            child: Text(
              'Dish Classification',
              style: GoogleFonts.nunito(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF0E4A06)),
            ),
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FoodHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter, // Centers content horizontally but keeps it at the top
        child: Padding(
          padding: const EdgeInsets.only(top: 65), // Adjust the top spacing
          child: Column(
            mainAxisSize: MainAxisSize.min, // Keeps the column from taking full height
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFF0E4A06), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(_image!.path),
                    fit: BoxFit.cover,
                  ),
                )
                    : const Center(
                  child: Text(
                    "No image selected",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              if (_foodResult != null)
                Text(
                  _foodResult!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 45),
              Wrap(
                spacing: 20,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Take a Photo"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      backgroundColor: Color(0xFF5D8736),
                      foregroundColor: Color(0xFFF4FFC3),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _uploadDish,
                    icon: const Icon(Icons.upload),
                    label: const Text("Upload from Gallery"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 33, vertical: 14),
                      backgroundColor: Color(0xFF5D8736),
                      foregroundColor: Color(0xFFF4FFC3),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 25),
                      ElevatedButton.icon(
                        onPressed: _foodResult != null && !_foodResult!.contains("Error") ? _getAdvice : null,
                        icon: const Icon(Icons.insights),
                        label: const Text("View Result"),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 65, vertical: 14),
                          backgroundColor: Color(0xFF5D8736),
                          foregroundColor: Color(0xFFF4FFC3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }


}
