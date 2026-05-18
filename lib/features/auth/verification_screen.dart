import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/otp_input.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ── ADDED IMPORT ──
import 'all_set.dart';

class VerificationScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String? gender;
  final String phoneNumber;
  final String verificationId;
  final String? location;
  final double? latitude;
  final double? longitude;

  const VerificationScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.gender,
    required this.phoneNumber,
    required this.verificationId,
    this.location,
    this.latitude,
    this.longitude,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String _otp = '';
  bool _isVerifying = false;

  Future<void> _saveUserToFirestore(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'firstName': widget.firstName,
      'lastName': widget.lastName,
      'email': widget.email,
      'gender': widget.gender,
      'phoneNumber': widget.phoneNumber,
      'location': widget.location,
      'latitude': widget.latitude,
      'longitude': widget.longitude,
      'preferredLanguage': 'en', // Cloud memory set to English
      'createdAt': FieldValue.serverTimestamp(),
      'role': 'buyer',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppTopBar(title: 'Verifying'),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            const Text(
              'Enter Verification code',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                color: AppColors.secondary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent you a code via SMS.',
              style: TextStyle(
                color: AppColors.secondary.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            OtpInput(
              length: 6,
              onChanged: (v) => setState(() => _otp = v),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Resend code?',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: _isVerifying ? 'Verifying...' : 'Continue',
              onPressed: _isVerifying ? null : () async {
                setState(() => _isVerifying = true);
                final nav = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                try {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                    verificationId: widget.verificationId,
                    smsCode: _otp,
                  );

                  UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(credential);

                  if (userCred.user != null) {
                    await _saveUserToFirestore(userCred.user!.uid);
                    await userCred.user!.updateDisplayName('${widget.firstName} ${widget.lastName}');

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('language', 'en');

                    nav.pushReplacement(MaterialPageRoute(builder: (_) => AllSetScreen(
                      firstName: widget.firstName,
                      lastName: widget.lastName,
                    )));
                  }
                } catch (e) {
                  messenger.showSnackBar(const SnackBar(content: Text('Incorrect code. Please try again.')));
                } finally {
                  if (mounted) setState(() => _isVerifying = false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
