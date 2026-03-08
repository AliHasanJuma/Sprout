import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';
import 'login_screen.dart';
import 'verification_screen.dart';

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
  final FocusNode _phoneFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Start with empty string - the visual +973 is already on the left
    _phoneController.text = '';
    _phoneFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    // The listener is automatically removed when the focus node is disposed.
    _phoneFocusNode.dispose();
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
    
    // TODO: Add actual backend logic AND REMOVE THE PRINT STATEMENT ABOVE IT'S ONLY USED FOR TESTING VALUES
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationScreen(
          firstName: widget.firstName,
          lastName: widget.lastName,
          email: widget.email,
          gender: widget.gender,
          phoneNumber: phoneNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = _phoneFocusNode.hasFocus
        ? const Color(0xFFDAF64F)
        : const Color(0xFFDEDEDE);

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
          'Phone Number',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontWeight: FontWeight.w400,
            color: AppColors.secondary,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your phone number',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Color(0xFF003E3B),
              ),
            ),
            const SizedBox(height: 8),
            
            // Phone number field with Bahrain country code
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: borderColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Country code (non-editable)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.1),
                    ),
                    child: Text(
                      '+973',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromARGB(255, 0, 0, 0),
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
                      focusNode: _phoneFocusNode,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 9,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      decoration: const InputDecoration(
                        hintText: '3333 3333',
                        hintStyle: TextStyle(color: Color(0xFFC3C3C3)),
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
            
            const SizedBox(height: 48),
            
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