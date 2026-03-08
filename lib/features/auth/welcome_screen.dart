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
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              // Top section with logo and text - pushed up
              Container(
                margin: const EdgeInsets.only(top: 210), // Adjust this value to position higher/lower
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dark green logo - left aligned
                    Transform.translate(
                      offset: const Offset(0, 0), 
                      child: Image.asset(
                        'assets/logo/logodark_green.png', 
                        width: 200, 
                        height: 40,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Connect,\nCraft & Share.',
                      style: TextStyle(
                        fontSize: 40, // Bigger
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w900,
                        color: Color.fromARGB(255, 0, 0, 0), // Dark green to match logo
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
                  
                  const SizedBox(height: 8),
                  
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