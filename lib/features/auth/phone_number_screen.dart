import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, defaultTargetPlatform;
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
  final String? location;
  final double? latitude;
  final double? longitude;

  const PhoneNumberScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.gender,
    this.location,
    this.latitude,
    this.longitude,
  });

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = '';
    _phoneFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
if (kDebugMode) {
  await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
}
    String phoneNumber = _phoneController.text.replaceAll(' ', '');
    if (phoneNumber.length != 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 8-digit phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    String fullNumber = '+973$phoneNumber';
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Only for native iOS Simulator
    if (!kIsWeb && kDebugMode && defaultTargetPlatform == TargetPlatform.iOS) {
      await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (mainly Android)
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (mounted) {
            setState(() => _isLoading = false);
            messenger.showSnackBar(SnackBar(content: Text(e.message ?? "Verification failed")));
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
                  location: widget.location,
                  latitude: widget.latitude,
                  longitude: widget.longitude,
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
        messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Standard build UI (same as your current one)
    final Color borderColor = _phoneFocusNode.hasFocus ? const Color(0xFFDAF64F) : const Color(0xFFDEDEDE);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/UI icons package/PNG/Black/Arrow/Arrow_Left_MD.png', width: 24, height: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Phone Number', style: TextStyle(color: AppColors.secondary)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor)),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(16), child: const Text('+973', style: TextStyle(fontSize: 16))),
                  Container(width: 2, height: 30, color: AppColors.primary),
                  Expanded(
                    child: TextField(
                      focusNode: _phoneFocusNode, controller: _phoneController,
                      keyboardType: TextInputType.phone, maxLength: 9,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      decoration: const InputDecoration(hintText: '3333 3333', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16)),
                      onChanged: (value) {
                        String digits = value.replaceAll(' ', '');
                        if (digits.length > 8) digits = digits.substring(0, 8);
                        String formatted = digits.length <= 4 ? digits : '${digits.substring(0, 4)} ${digits.substring(4)}';
                        _phoneController.text = formatted;
                        _phoneController.selection = TextSelection.fromPosition(TextPosition(offset: _phoneController.text.length));
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(text: _isLoading ? 'Sending...' : 'Continue', onPressed: _isLoading ? null : _handleContinue),
          ],
        ),
      ),
    );
  }
}