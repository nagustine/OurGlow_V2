import 'package:flutter/material.dart';
import 'theme/theme.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const OurGlowApp());
}

class OurGlowApp extends StatelessWidget {
  const OurGlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OurGlow — Skincare Checker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}