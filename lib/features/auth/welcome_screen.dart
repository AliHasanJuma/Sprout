import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Connect, Craft & Share.',
                      style: TextStyle(
                        fontSize: 50, // Bigger
                        fontWeight: FontWeight.bold, // Bolder
                        color: AppColors.secondary, // Dark green to match logo
                        height: 1.2, // Tighter line height
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
                  // Sign Up button - secondary color (dark green) with white text
                  CustomButton(
                    text: 'Sign Up',
                    onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                    },
                    backgroundColor: AppColors.secondary,
                    textColor: Colors.white,
                    isOutlined: false,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Log In button - primary color (neon green) with dark green text
                  CustomButton(
                    text: 'Log In',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    backgroundColor: AppColors.primary,
                    textColor: AppColors.secondary,
                    isOutlined: false,
                  ),
                  
                  const SizedBox(height: 30), // Bottom padding
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}