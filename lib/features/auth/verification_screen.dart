import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'login_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String? gender;
  final String phoneNumber;

  const VerificationScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.gender,
    required this.phoneNumber,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1) {
      // Move to next field
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    } else if (value.isEmpty) {
      // Move to previous field on delete
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
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
          'Verifying',
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            // Big bold text
            const Center(
              child: Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Smaller text with phone number
            Center(
              child: Text(
                'We sent you a code via SMS.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondary.withValues(alpha: 0.7),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Six OTP boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return Container(
                  width: 50,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => _onChanged(value, index),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 30),
            
            // Resend code text (bold, no functionality)
            const Center(
              child: Text(
                'Resend code?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Continue button
            CustomButton(
              text: 'Continue',
              onPressed: () {
                // Get all digits
                String code = '';
                for (var controller in _controllers) {
                  code += controller.text;
                }
                print('Verification code: $code');
                print('All user data:');
                print('First Name: ${widget.firstName}');
                print('Last Name: ${widget.lastName}');
                print('Email: ${widget.email}');
                print('Gender: ${widget.gender}');
                print('Phone: ${widget.phoneNumber}');
                
                // TODO: Verify code and complete signup
              },
              backgroundColor: AppColors.primary,
              textColor: Colors.black,
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}