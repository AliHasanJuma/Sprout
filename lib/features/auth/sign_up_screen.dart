import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'login_screen.dart';
import '../../shared/widgets/custom_textfield.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? _selectedGender; // Track selected gender

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleSignUp() { // signup handler
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String email = _emailController.text;
    String? gender = _selectedGender;
  
    print('First Name: $firstName');
    print('Last Name: $lastName');
    print('Email: $email');
    print('Gender: $gender');
  
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
  
  // TODO: Add actual sign up logic AND REMOVE THE PRINT STATEMENT ABOVE IT'S ONLY USED FOR TESTING VALUES
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
          'Create an Account',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Makes screen scrollable for keyboard
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Name
              CustomTextField(
                label: 'First Name',
                hintText: 'Enter your first name',
                controller: _firstNameController,
              ),

              const SizedBox(height: 20),
              
              // Last Name
              CustomTextField(
                label: 'Last Name',
                hintText: 'Enter your last name',
                controller: _lastNameController,
              ),
              
              const SizedBox(height: 20),
              
              // Gender
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Male button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGender = 'Male';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedGender == 'Male' 
                              ? AppColors.primary 
                              : AppColors.tertiary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: _selectedGender != 'Male'
                              ? Border.all(color: Colors.grey.withValues(alpha: 0.3))
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Male',
                            style: TextStyle(
                              color: _selectedGender == 'Male' 
                                  ? Colors.black 
                                  : AppColors.secondary,
                              fontWeight: _selectedGender == 'Male' 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Female button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGender = 'Female';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedGender == 'Female' 
                              ? AppColors.primary 
                              : AppColors.tertiary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: _selectedGender != 'Female'
                              ? Border.all(color: Colors.grey.withValues(alpha: 0.3))
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            'Female',
                            style: TextStyle(
                              color: _selectedGender == 'Female' 
                                  ? Colors.black 
                                  : AppColors.secondary,
                              fontWeight: _selectedGender == 'Female' 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Email
              CustomTextField(
                label: 'Email',
                hintText: 'example@gmail.com',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              
              const SizedBox(height: 30),
              
              // Continue button
              CustomButton(
                text: 'Continue',
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
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}