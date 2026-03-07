import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';
import 'login_screen.dart';
import 'verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneNumberScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String? gender;

  const PhoneNumberScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.gender,
  });

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start with empty string - the visual +973 is already on the left
    _phoneController.text = '';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    // Get just the digits (remove any spaces)
    String phoneNumber = _phoneController.text.replaceAll(' ', '');
    
    print('First Name: ${widget.firstName}');
    print('Last Name: ${widget.lastName}');
    print('Email: ${widget.email}');
    print('Gender: ${widget.gender}');
    print('Phone: $phoneNumber');
    
    if (phoneNumber.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 8-digit phone number')),
      );
      return;
    }
    
    // Full number with country code for backend
    String fullNumber = '+973$phoneNumber';
    print('Full number for API: $fullNumber');
    
    FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: fullNumber,

  verificationCompleted: (PhoneAuthCredential credential) async {
    await FirebaseAuth.instance.signInWithCredential(credential);
  },

  verificationFailed: (FirebaseAuthException e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? "Verification failed")),
    );
  },

  codeSent: (String verificationId, int? resendToken) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationScreen(
          firstName: widget.firstName,
          lastName: widget.lastName,
          email: widget.email,
          gender: widget.gender,
          phoneNumber: fullNumber,
          verificationId: verificationId,
        ),
      ),
    );

  },

  codeAutoRetrievalTimeout: (String verificationId) {},
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
          icon: Icon(Icons.arrow_back_ios, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Phone Number',
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
            Text(
              'Enter your phone number',
              style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 8),
            
            // Phone number field with Bahrain country code
            Container(
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  // Country code (non-editable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      '+973',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  
                  // Vertical divider line
                  Container(
                    width: 2,
                    height: 30,
                    color: AppColors.primary,
                  ),
                  
                  // Phone number input
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 9,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      decoration: const InputDecoration(
                        hintText: '3333 3333',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (value) {
                        // Remove any spaces to get just digits
                        String digits = value.replaceAll(' ', '');
                        
                        // Limit to 8 digits
                        if (digits.length > 8) {
                          digits = digits.substring(0, 8);
                        }
                        
                        // Format the digits with a space after 4 digits
                        String formattedDigits = '';
                        if (digits.length <= 4) {
                          formattedDigits = digits;
                        } else {
                          formattedDigits = '${digits.substring(0, 4)} ${digits.substring(4)}';
                        }
                        
                        // Update the text with ONLY the formatted digits
                        if (_phoneController.text != formattedDigits) {
                          _phoneController.text = formattedDigits;
                          
                          // Move cursor to the end
                          _phoneController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _phoneController.text.length),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Continue button
            CustomButton(
              text: 'Continue',
              onPressed: _handleContinue,
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
          ],
        ),
      ),
    );
  }
}