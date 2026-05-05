import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';
import 'sign_up_screen.dart';
import '../buyer_ui/Mainscreen.dart'; 

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

  Future<void> _handleLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // Navigate to buyer UI homepage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()), 
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Invalid email or password';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
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
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: 'Log In'),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Log in to continue',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            
            // Email field
            CustomTextField(
              label: 'Email',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
            ),
            
            const SizedBox(height: 16),
            
            // Password field
            CustomTextField(
              label: 'Password',
              hintText: 'Enter your password',
              obscureText: true,
              controller: _passwordController,
            ),
            
            const SizedBox(height: 48),
            
            // Log In button
            CustomButton(
              text: 'Log In',
              onPressed: _handleLogin,
            ),
            
            const SizedBox(height: 8),
            
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
            
            const SizedBox(height: 16),
            
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