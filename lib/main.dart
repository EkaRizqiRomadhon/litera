import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const LiteraApp());
}

class LiteraApp extends StatelessWidget {
  const LiteraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Litera',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'serif',
        scaffoldBackgroundColor: const Color(0xFFF5F0EB),
      ),
      home: const SplashScreen(),
    );
  }
}
