import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase init error - app akan tetap berjalan tapi auth tidak akan bekerja
    debugPrint('Firebase initialization error: $e');
  }
  
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
        fontFamily: 'inter',
        scaffoldBackgroundColor: const Color(0xFFF5F0EB),
      ),
      home: const SplashScreen(),
    );
  }
}
