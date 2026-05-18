import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ── 1. ADDED THIS IMPORT ──
import 'core/constants/app_colors.dart';
import 'features/auth/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ── NEW APP CHECK IMPORT ──
import 'package:firebase_app_check/firebase_app_check.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // This locks the entire app to portrait mode globally
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── NEW APP CHECK ACTIVATION ──
  // This forces the emulator to generate a debug token so Firebase trusts it
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sprout',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(), 
    );
  }
}