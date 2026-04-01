import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode;
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

  bool _isLoading = false;

  Future<void> _handleContinue() async {
    // Get just the digits (remove any spaces)
    String phoneNumber = _phoneController.text.replaceAll(' ', '');

    if (phoneNumber.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 8-digit phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Full number with country code for backend
    String fullNumber = '+973$phoneNumber';

    // On iOS Simulator in debug mode, disable app verification since
    // APNs is unavailable and reCAPTCHA fallback requires REVERSED_CLIENT_ID.
    // This prevents the native Swift assertion crash (EXC_BREAKPOINT).
    // NOTE: You must also add a test phone number in Firebase Console:
    //   Authentication → Phone → Phone numbers for testing
    //   e.g. +973 3333 3333 with code 123456
    if (kDebugMode && Platform.isIOS) {
      FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
    }

    // Capture context-dependent objects before the async gap
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullNumber,

        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
          } catch (e) {
            if (mounted) {
              messenger.showSnackBar(
                SnackBar(content: Text('Auto-verification failed: $e')),
              );
            }
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            setState(() => _isLoading = false);
            messenger.showSnackBar(
              SnackBar(content: Text(e.message ?? "Verification failed")),
            );
          }
        },

        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() => _isLoading = false);
            nav.push(
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
          }
        },

        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        messenger.showSnackBar(
          SnackBar(content: Text('Phone verification error: $e')),
        );
      }
    }
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
              text: _isLoading ? 'Sending...' : 'Continue',
              onPressed: _isLoading ? null : _handleContinue,
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