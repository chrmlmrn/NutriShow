import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PortionEstimatorHackPage(),
  ));
}

class PortionEstimatorHackPage extends StatefulWidget {
  const PortionEstimatorHackPage({Key? key}) : super(key: key);

  @override
  State<PortionEstimatorHackPage> createState() => _PortionEstimatorHackPageState();
}

class _PortionEstimatorHackPageState extends State<PortionEstimatorHackPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  Interpreter? _thumbClassifier;
  Map<String, double>? result;
  bool isLoading = false;
  bool thumbDetected = false;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    _thumbClassifier = await Interpreter.fromAsset('assets/thumb_MobileNetV2_v5.tflite');
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        result = null;
        isLoading = true;
        thumbDetected = false;
      });
      await runThumbDetection(File(pickedFile.path));
    }
  }

  Future<void> runThumbDetection(File imageFile) async {
    final input = await _preprocessImage(imageFile);

    final output = List.filled(1, 0.0).reshape([1, 1]);
    _thumbClassifier!.run(input, output);

    thumbDetected = output[0][0] > 0.9;

    if (thumbDetected) {
      result = estimateFoodPortion();
    } else {
      result = null;
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(File imageFile) async {
    final rawImage = await imageFile.readAsBytes();
    final image = img.decodeImage(rawImage);

    final resizedImage = img.copyResize(image!, width: 224, height: 224);

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

  Map<String, double> estimateFoodPortion() {
    const int imageSize = 300;
    const double assumedThumbWidthPx = imageSize * 0.2;
    const double realThumbWidthCm = 2.0;

    double pixelToCmRatio = realThumbWidthCm / assumedThumbWidthPx;

    double foodWidthPx = imageSize - assumedThumbWidthPx;
    double foodHeightPx = imageSize.toDouble();

    double foodWidthCm = foodWidthPx * pixelToCmRatio;
    double foodHeightCm = foodHeightPx * pixelToCmRatio;
    double foodAreaCm2 = foodWidthCm * foodHeightCm;

    return {
      'pixelToCmRatio': pixelToCmRatio,
      'foodWidthCm': foodWidthCm,
      'foodHeightCm': foodHeightCm,
      'foodAreaCm2': foodAreaCm2,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thumb Classifier + Portion Estimator"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          if (_image != null)
            Stack(
            Stack(
              alignment: Alignment.center,
              children: [
                Image.file(_image!, height: 300),
                if (thumbDetected)
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                    ),
                  )
              ],
            )
          else
            const Text("Upload or Take a Picture"),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: isLoading ? null : () => pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo),
                label: const Text("Upload"),
              ),
              ElevatedButton.icon(
                onPressed: isLoading ? null : () => pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Camera"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const CircularProgressIndicator()
          else if (thumbDetected && result != null)
            Card(
              elevation: 5,
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text("Estimated Portion"),
                    Text("Pixel Ratio: ${result!['pixelToCmRatio']!.toStringAsFixed(3)} cm/px"),
                    Text("Food Width: ${result!['foodWidthCm']!.toStringAsFixed(2)} cm"),
                    Text("Food Height: ${result!['foodHeightCm']!.toStringAsFixed(2)} cm"),
                    Text("Food Area: ${result!['foodAreaCm2']!.toStringAsFixed(2)} cm²"),
                  ],
                ),
              ),
            )
          else if (!thumbDetected && _image != null)
              const Text("No thumb detected in the image."),
        ],
      ),
    );
  }
}
