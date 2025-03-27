import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrishow/database/database_service.dart';
import 'package:nutrishow/database/food_history.dart';
import 'package:nutrishow/views/advice.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
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
  String? _thumbResult;
  late Interpreter _foodInterpreter;
  late Interpreter _thumbInterpreter;
  late List<String> _labels;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    _foodInterpreter = await Interpreter.fromAsset('assets/mobilenetv2_food_classifier.tflite');
    _thumbInterpreter = await Interpreter.fromAsset('assets/thumb_MobileNetV2_v5.tflite');
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

  Future<void> _runBothDetections() async {
    if (_image == null) return;

    try {
      final input = await _preprocessImage(File(_image!.path));
      if (input == null) {
        throw Exception("Failed to preprocess image.");
      }

      // Thumb detection
      final thumbOutput = List.filled(1, 0.0).reshape([1, 1]);
      _thumbInterpreter.run(input, thumbOutput);
      bool isThumb = thumbOutput[0][0] > 0.99;
      print('Raw thumb model output: ${thumbOutput[0][0]}');

      // Food classification
      final foodOutput = List.filled(101, 0.0).reshape([1, 101]);
      _foodInterpreter.run(input, foodOutput);

      final predictions = foodOutput[0]
          .asMap()
          .entries
          .map((entry) => {'label': _labels[entry.key], 'confidence': entry.value})
          .toList()
        ..sort((a, b) => (b['confidence'] as double).compareTo(a['confidence'] as double));

      setState(() {
        _foodResult = '${predictions[0]["label"]} (${(predictions[0]["confidence"] * 100).toStringAsFixed(2)}%)';
        _thumbResult = isThumb
            ? 'Thumb detected (${(thumbOutput[0][0] * 100).toStringAsFixed(2)}%)'
            : 'No thumb detected';

        print(_thumbResult);

      });
    } catch (e) {
      print("Error during inference: $e");
      setState(() {
        _foodResult = "Error during inference.";
        _thumbResult = "Error during inference.";
      });
    }
  }

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _image = photo;
        _foodResult = null;
        _thumbResult = null;
      });
      await _runBothDetections();
    }
  }

  Future<void> _uploadDish() async {
    final photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      setState(() {
        _image = photo;
        _foodResult = null;
        _thumbResult = null;
      });
      await _runBothDetections();
    }
  }

  Future<void> _getAdvice() async {
    if (_foodResult == null) return;

    String foodName = _foodResult!.split(" (")[0].trim();
    print("Predicted Food Name: $foodName");

    DatabaseHelper dbHelper = DatabaseHelper();
    Map<String, dynamic>? foodDetails = await dbHelper.getFoodDetails(foodName);

    if (foodDetails != null) {
      await FoodHistory.addToHistory(foodDetails);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MacronutrientAdvicePage(foodDetails: foodDetails),
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
    _thumbInterpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
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
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _foodResult ?? "",
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _foodResult != null && !_foodResult!.contains("Error") ? _getAdvice : null,
              child: const Text("View Result"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _takePhoto,
              child: const Text("Take a Photo of a Dish"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _uploadDish,
              child: const Text("Upload a Dish"),
            ),
          ],
        ),
      ),
    );
  }
}
