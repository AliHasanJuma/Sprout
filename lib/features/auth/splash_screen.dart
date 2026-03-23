import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import 'welcome_screen.dart';
import '../buyer_ui/Mainscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () async {
      // authStateChanges().first waits for Firebase to restore the persisted
      // session before we decide — more reliable than currentUser on cold start
      // across all platforms (Android, iOS, web).
      final user = await FirebaseAuth.instance.authStateChanges().first;
      if (!mounted) return;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary, // Neon green background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo/logoBlack.png',
              width: 320,  // Same size as native splash
              height: 320, // Same size as native splash
            ),
            
            const SizedBox(height: 48), // Space between logo and loader
            
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: AppColors.secondary.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}