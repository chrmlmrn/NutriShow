import 'dart:io';
import 'dart:math';
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
  String? _portionSize;
  String? _foodId;
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

      String foodName = predictions[0]["label"];
      setState(() {
        _foodResult = '$foodName (${(predictions[0]["confidence"] * 100).toStringAsFixed(2)}%)';
        _foodId = foodName; // Store the food name or map it to the food ID
      });

      // Fetch the portion type after the food detection
      String portionType = await _getPortionTypeFromDatabase(foodName);
      print("Portion type: $portionType");

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
        _portionSize = null;
        _foodId = null;
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
        _portionSize = null;
        _foodId = null;
      });
      await _runDetection();
    }
  }

  Future<void> _showPortionInputDialog() async {
    if (_foodId == null) {
      return;
    }

    TextEditingController _controller = TextEditingController();
    DatabaseHelper dbHelper = DatabaseHelper();

    String portionType = 'Unknown';
    double servingSize = 0.0;

    try {
      final db = await dbHelper.database;

      // Get food_uid
      var foodIdResult = await db.rawQuery(
        '''
      SELECT food_uid
      FROM food_items
      WHERE LOWER(food_name) = ?
      ''',
        [_foodId!.trim().toLowerCase()],
      );

      if (foodIdResult.isNotEmpty) {
        String foodUid = foodIdResult.first['food_uid'] as String;

        // Get portion and serving size
        var result = await db.rawQuery(
          '''
        SELECT portion, serving_size
        FROM food_servings
        WHERE food_uid = ?
        ''',
          [foodUid],
        );

        if (result.isNotEmpty) {
          portionType = result.first['portion']?.toString() ?? 'Unknown';
          servingSize = double.tryParse(result.first['serving_size'].toString()) ?? 0.0;
        }
      }
    } catch (e) {
      print("Error fetching portion info: $e");
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Portion Size"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Serving Type: 1 $portionType"),
              if (servingSize > 0)
                Text("Serving Size: $servingSize g"),
              const SizedBox(height: 8),
              const Text("Enter how many servings (e.g. 1 or 1/2 (0.5):"),
              TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: "e.g. 1 or 1/2",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("OK"),
              onPressed: () {
                setState(() {
                  _portionSize = _controller.text;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }



  // This method will query the database to get the portion type for the given foodId
  Future<String> _getPortionTypeFromDatabase(String foodName) async {
    DatabaseHelper dbHelper = DatabaseHelper();

    try {
      // Step 1: Fetch the food_uid from the food_items table using food_name
      final db = await dbHelper.database; // Get the database instance
      var foodIdResult = await db.rawQuery(
        '''
      SELECT food_uid
      FROM food_items
      WHERE LOWER(food_name) = ?
      ''',
        [foodName.trim().toLowerCase()],
      );

      // Debug: Log the foodId
      print("Food UID for $foodName: $foodIdResult");

      if (foodIdResult.isNotEmpty) {
        String foodUid = foodIdResult.first['food_uid'] as String;

        // Step 2: Query the portion type from the food_servings table using the food_uid
        var result = await db.rawQuery(
          '''
        SELECT portion
        FROM food_servings
        WHERE food_uid = ?
        ''',
          [foodUid],
        );

        // Check if the result is not empty and return the portion
        if (result.isNotEmpty && result.first['portion'] != null) {
          return result.first['portion'] as String;
        } else {
          throw Exception("Portion not found for food UID: $foodUid");
        }
      } else {
        throw Exception("Food UID not found for food name: $foodName");
      }
    } catch (e) {
      print("Error fetching portion type: $e");
      return 'Unknown';  // Fallback if an error occurs
    }
  }



  Future<void> _getAdvice() async {
    if (_foodResult == null) return;

    String foodName = _foodResult!.split(" (")[0].trim();
    print("Predicted Food Name: $foodName");

    DatabaseHelper dbHelper = DatabaseHelper();
    Map<String, dynamic>? foodDetails = await dbHelper.getFoodDetails(foodName);

    if (foodDetails != null) {
      int userAge = 25;
      String userGender = "Male";
      String userActivity = "Moderately Active";

      Map<String, dynamic> recommendedRow = await dbHelper.getRecommendedIntakeRow(userAge);

      Map<String, dynamic> assessment = dbHelper.assessDiet(
        foodData: foodDetails,
        recommendedRow: recommendedRow,
        gender: userGender,
        activity: userActivity,
        portionSize: _portionSize,
      );

      // 🧠 Dietary Tips
      final List<String> bothTips = [
        "Please make sure to cut the nutrient intake for those with too much and consume more for those lacking/less.",
        "Make necessary dietary changes by limiting overconsumed nutrients and increasing those that are lacking.",
        "Improve your nutrient balance by eating less of what’s excessive and more of what’s insufficient.",
        "Moderate your nutrient levels—reduce excesses and supplement deficiencies accordingly.",
        "Ensure proper nutrition by decreasing overconsumed nutrients and boosting underconsumed ones.",
        "Regulate your diet by lowering excessive nutrients and increasing those in short supply.",
        "Optimize your nutrient intake by consuming less of what’s excessive and more of what’s insufficient.",
        "Maintain a healthy balance by reducing nutrients that exceed recommendations and increasing those that fall short.",
        "Keep your nutrient intake in check by lowering what’s too much and adding what’s too little.",
        "Ensure a well-rounded diet by consuming less of what you have too much of and more of what you need.",
        "Correct imbalances in your diet by lowering high nutrient levels and raising low ones.",
        "Manage your nutrition by reducing excessive intake and boosting nutrients that are below recommended levels.",
        "Strive for a balanced diet by cutting down on overconsumed nutrients and replenishing deficiencies.",
        "Adjust your food choices to decrease excess nutrients and increase those that are lacking.",
        "Make dietary adjustments by limiting excess nutrients and incorporating more of the ones you’re missing.",
      ];

      final List<String> tooMuchOnlyTips = [
        "Your intake shows excess in certain nutrients; please reduce their consumption.",
        "Certain nutrients are higher than necessary—moderate your intake accordingly.",
        "Some nutrients exceed healthy limits—consider adjusting your diet to lower them.",
        "Too much of certain nutrients was detected—lowering your intake is advised.",
        "Some nutrients are above the recommended levels—consider lowering your intake.",
      ];

      final List<String> lackingOnlyTips = [
        "Your diet is lacking certain nutrients—consider consuming more of them.",
        "Your intake is below optimal levels for certain nutrients—add more to your meals.",
        "Below-recommended nutrient levels found—consider eating more of the right foods.",
        "To meet your nutritional needs, increase intake of the nutrients you're currently lacking.",
        "Some important nutrients are insufficient—incorporate more of them into your diet.",
      ];

      final tooMuch = assessment['too_much'] as List? ?? [];
      final lacking = assessment['lacking'] as List? ?? [];

      String selectedTip;
      if (tooMuch.isNotEmpty && lacking.isNotEmpty) {
        selectedTip = bothTips[Random().nextInt(bothTips.length)];
      } else if (tooMuch.isNotEmpty) {
        selectedTip = tooMuchOnlyTips[Random().nextInt(tooMuchOnlyTips.length)];
      } else if (lacking.isNotEmpty) {
        selectedTip = lackingOnlyTips[Random().nextInt(lackingOnlyTips.length)];
      } else {
        selectedTip = "You're on track with your nutrient intake! Keep it up!";
      }

      // Save to history
      await FoodHistory.addToHistory(
        foodDetails: foodDetails,
        assessment: assessment,
        recommendedIntake: recommendedRow,
        gender: userGender,
        portionSize: _portionSize,
        tip: selectedTip,
      );

      // Navigate to advice page with selected tip
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MacronutrientAdvicePage(
            foodDetails: foodDetails,
            assessment: assessment,
            recommendedIntake: recommendedRow,
            gender: userGender,
            portionSize: _portionSize,
            tip: selectedTip,
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
        title: Center(
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 65, left: 20, right: 20, bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.center, // Center the image container
                child: Container(
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
              ),
              const SizedBox(height: 25),
              if (_foodResult != null)
                Text(
                  _foodResult!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              if (_portionSize != null)
                Text(
                  "Portion: $_portionSize",
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
                ),
              const SizedBox(height: 45),
              Column(
                mainAxisSize: MainAxisSize.min, // Ensure all buttons stack up and are centered
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
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _foodId != null ? _showPortionInputDialog : null, // Only allow showing dialog if foodId is set
                    icon: const Icon(Icons.edit),
                    label: const Text("Enter Portion"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      backgroundColor: Color(0xFF5D8736),
                      foregroundColor: Color(0xFFF4FFC3),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_portionSize == null || _portionSize!.isEmpty)
                    Text(
                      "Please enter portion size before viewing result.",
                      style: TextStyle(color: Colors.red.shade700, fontStyle: FontStyle.italic),
                    ),

                  ElevatedButton.icon(
                    onPressed: (_foodResult != null && !_foodResult!.contains("Error") && _portionSize != null && _portionSize!.isNotEmpty)
                        ? _getAdvice
                        : null,
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
        ),
      ),
    );
  }
}
