import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DishOptionsScreen extends StatefulWidget {
  const DishOptionsScreen({super.key});

  @override
  _DishOptionsScreenState createState() => _DishOptionsScreenState();
}

class _DishOptionsScreenState extends State<DishOptionsScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  // Method to pick image from camera
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = photo;
    });
  }

  // Method to pick image from gallery
  Future<void> _uploadDish() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = photo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dish Options'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _takePhoto,
              child: const Text("Take a Photo of a Dish"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadDish,
              child: const Text("Upload a Dish"),
            ),
            const SizedBox(height: 30),
            _image != null
                ? Image.file(
              File(_image!.path),
              width: 200,
              height: 200,
            )
                : const Text("No image selected"),
          ],
        ),
      ),
    );
  }
}