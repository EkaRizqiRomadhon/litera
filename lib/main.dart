import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/navigation_controller.dart';
import 'controllers/profile_controller.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'pages/splash_page.dart';
import 'providers/book_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/reading_provider.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.dark,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileController>(
          create: (_) => ProfileController(),
        ),
        ChangeNotifierProvider<NavigationController>(
          create: (_) => NavigationController(),
        ),
        ChangeNotifierProvider<BookProvider>(
          create: (_) => BookProvider(),
        ),
        ChangeNotifierProvider<BookmarkProvider>(
          create: (_) => BookmarkProvider(),
        ),
        ChangeNotifierProvider<ReadingProvider>(
          create: (_) => ReadingProvider(),
        ),
      ],
      child: const LiteraApp(),
    ),
  );
}

class LiteraApp extends StatelessWidget {
  const LiteraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Litera',
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2D5A41),
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2D5A41),
              brightness: Brightness.dark,
            ),
          ),
          themeMode: currentMode,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashPage();
              }

              if (snapshot.hasData) {
                // Mulai Firestore listeners saat user login
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<BookmarkProvider>().startListening();
                  context.read<ReadingProvider>().startListening();
                });
                return const MainPage();
              }

              // Stop listeners saat logout
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<BookmarkProvider>().stopListening();
                context.read<ReadingProvider>().stopListening();
              });

              return const LoginPage();
            },
          ),
        );
      },
    );
  }
}
