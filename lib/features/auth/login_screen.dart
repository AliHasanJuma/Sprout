import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:my_app/features/auth/welcome_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';
import 'sign_up_screen.dart';
import 'homescreen.dart';

class LoginScreen extends StatefulWidget {  
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {  
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {  // login handler
  
    try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
    

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Homescreen()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  } 

  }

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
            const Center(
              child: Text(
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
            
            // Email field
            CustomTextField(
              label: 'Email',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            
            const SizedBox(height: 20),
            
            // Password field
            CustomTextField(
              label: 'Password',
              hintText: 'Enter your password',
              obscureText: true,
              controller: _passwordController,
            ),
            
            const SizedBox(height: 30),
            
            // Log In button
            CustomButton(
              text: 'Log In',
              onPressed: _handleLogin,  // uses handler initialized above
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