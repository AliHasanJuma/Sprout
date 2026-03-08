import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';
import 'login_screen.dart';
import 'phone_number_screen.dart';


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

     // Navigate to phone number screen with all data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhoneNumberScreen(
          firstName: firstName,
          lastName: lastName,
          email: email,
          gender: gender,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            'assets/UI icons package/PNG/Black/Arrow/Arrow_Left_MD.png',
            width: 24,
            height: 24,
            color: const Color(0xFF003E3B),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create an Account',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 20,
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Makes screen scrollable for keyboard
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First Name
              CustomTextField(
                label: 'First Name',
                hintText: 'Enter your first name',
                controller: _firstNameController,
              ),

              const SizedBox(height: 16),
              
              // Last Name
              CustomTextField(
                label: 'Last Name',
                hintText: 'Enter your last name',
                controller: _lastNameController,
              ),
              
              const SizedBox(height: 16),
              
              // Gender
              const Text(
                'Gender',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF003E3B),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedGender == 'Male' 
                                ? const Color(0xFFDAF64F) 
                                : const Color(0xFFDEDEDE),
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Male',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              color: _selectedGender == 'Male' 
                                  ? const Color(0xFF003E3B) 
                                  : const Color(0xFFC3C3C3),
                              fontWeight: FontWeight.w400,
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _selectedGender == 'Female' 
                                ? const Color(0xFFDAF64F) 
                                : const Color(0xFFDEDEDE),
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Female',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              color: _selectedGender == 'Female' 
                                  ? const Color(0xFF003E3B) 
                                  : const Color(0xFFC3C3C3),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Email
              CustomTextField(
                label: 'Email',
                hintText: 'example@gmail.com',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              
              const SizedBox(height: 48),
              
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