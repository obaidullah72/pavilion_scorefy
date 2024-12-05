import 'dart:async';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // Get screen size for scaling
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.1, // Adjust the opacity as needed
            child: Image.asset(
              'assets/bg.jpg', // Replace with your asset path
              fit: BoxFit.cover,
            ),
          ),
          // Logo and text on top of the background
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/logo.png', // Replace with your logo path
                height: size.height * 0.4, // Adjust logo size
              ),
              const SizedBox(height: 20), // Spacing between logo and text
              // Text below the logo
              Text(
                "Pavilion Score", // Replace with your desired text
                style: TextStyle(
                  fontSize: size.width * 0.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
