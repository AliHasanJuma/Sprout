import 'package:flutter/material.dart';
import 'package:my_app/features/auth/welcome_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Homescreen extends StatelessWidget {
  const Homescreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Top section with logo and text - pushed up
              Container(
                margin: const EdgeInsets.only(top: 60), // Adjust this value to position higher/lower
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dark green logo - left aligned
                    Image.asset(
                      'assets/logo/logoDark_green.png', // Make sure this path is correct
                      width: 200, // Adjust size as needed
                      height: 200,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tagline - bigger, bolder, left aligned
                     Text(
  'Logged in as ${user?.phoneNumber ?? "Unknown"}',
  style: const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.secondary,
  ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              
              const Spacer(), // This pushes everything below to the bottom
              
              // Buttons section
              Column(
                children: [
                  // Sign out button - secondary color (dark green) with white text
                  CustomButton(
                    text: 'Sign Out',
                    onPressed: () async {
  await FirebaseAuth.instance.signOut();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    (route) => false,
  );
},
                    backgroundColor: AppColors.secondary,
                    textColor: Colors.white,
                    isOutlined: false,
                  ),
                  
                  const SizedBox(height: 16),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}