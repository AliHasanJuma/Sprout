import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Add this for tap recognizer
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart'; // Add this import
import 'sign_up_screen.dart'; // Add this for navigation

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Log In',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center( child:
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Log in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondary.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // Email field - Using new CustomTextField
            const CustomTextField(
              label: 'Email',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 20),
            
            // Password field - Using new CustomTextField
            const CustomTextField(
              label: 'Password',
              hintText: 'Enter your password',
              obscureText: true,
            ),
            
            const SizedBox(height: 30),
            
            // Log In button
            CustomButton(
              text: 'Log In',
              onPressed: () {
                // Handle login
              },
            ),
            
            const SizedBox(height: 16),
            
            // Forgot password?
            Center(
              child: TextButton(
                onPressed: () {
                  // Handle forgot password
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Don't have an account? Sign Up
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'Don\'t have an account? ',
                  style: TextStyle(
                    color: AppColors.secondary.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}