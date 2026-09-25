import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/theme.dart';
import 'screens/auth/login_register_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      initialRoute: '/home',
      routes: {
        '/login': (_) => const LoginRegisterScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}