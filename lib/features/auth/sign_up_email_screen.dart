import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';
import 'login_screen.dart';
import 'phone_number_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpEmailScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String? gender;
  final String? location;
  final double? latitude;
  final double? longitude;

  const SignUpEmailScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.gender,
    this.location,
    this.latitude,
    this.longitude,
  });

  @override
  State<SignUpEmailScreen> createState() => _SignUpEmailScreenState();
}

class _SignUpEmailScreenState extends State<SignUpEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateInputs(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      _showError('Please fill in all fields');
      return false;
    }

    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      _showError('Please enter a valid email address');
      return false;
    }

    final passwordRegExp = RegExp(
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#\$&*~`%^()_\-+={}[\]:;"<>,.?/\\]).{8,}$');
    if (!passwordRegExp.hasMatch(password)) {
      _showError(
          'Password must be at least 8 characters, with letters, numbers, and a special character');
      return false;
    }

    return true;
  }

  Future<void> _handleSignUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    if (!_validateInputs(email, password)) return;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneNumberScreen(
            firstName: widget.firstName,
            lastName: widget.lastName,
            email: email,
            gender: widget.gender,
            location: widget.location,   // Added
            latitude: widget.latitude,   // Added
            longitude: widget.longitude, // Added
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'An error occurred during sign up.');
    } catch (e) {
      _showError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: 'Create an Account'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Email
              CustomTextField(
                label: 'Email',
                hintText: 'example@gmail.com',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 16),

              // Password
              CustomTextField(
                label: 'Password',
                hintText: 'Enter your password',
                controller: _passwordController,
                obscureText: true,
              ),

              const SizedBox(height: 30),

              // Create Account button
              CustomButton(
                text: 'Create Account',
                onPressed: _handleSignUp,
                backgroundColor: AppColors.primary,
                textColor: Colors.black,
              ),

              const SizedBox(height: 20),

              // Already have an account? Log In
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(
                      color: AppColors.secondary.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: 'Log In',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
