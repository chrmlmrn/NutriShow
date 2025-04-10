import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrishow/views/user_input.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserInputView()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.png', // Replace with your background image
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.2), // Optional overlay for contrast
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 150,
                  height: 150,
                ),
                const SizedBox(height: 30),
                Text(
                  'NutriShow',
                  style: GoogleFonts.changaOne(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF4FFC3),
                  ),
                ),
                Text(
                  'Image In, Insights Out: \nTrack your food without a doubt',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF4FFC3).withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}