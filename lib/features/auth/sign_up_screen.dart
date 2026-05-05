import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';
import 'login_screen.dart';
import 'sign_up_email_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String? _selectedGender;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateInputs(
      String firstName, String lastName, String? gender) {
    if (firstName.isEmpty || lastName.isEmpty || gender == null) {
      _showError('Please fill in all fields');
      return false;
    }

    final nameRegExp = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegExp.hasMatch(firstName) || firstName.length > 30) {
      _showError(
          'First name must contain only letters/spaces and be under 30 characters');
      return false;
    }
    if (!nameRegExp.hasMatch(lastName) || lastName.length > 30) {
      _showError(
          'Last name must contain only letters/spaces and be under 30 characters');
      return false;
    }

    return true;
  }

  void _handleContinue() {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String? gender = _selectedGender;

    if (!_validateInputs(firstName, lastName, gender)) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpEmailScreen(
          firstName: firstName,
          lastName: lastName,
          gender: gender,
          location: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
          latitude: _latitude,
          longitude: _longitude,
        ),
      ),
    );
  }

  Future<void> _detectLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied');
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError(
            'Location permission permanently denied. Please enable it in Settings.');
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ?? place.subAdministrativeArea ?? '';
        final country = place.country ?? '';
        final locationText =
            [city, country].where((s) => s.isNotEmpty).join(', ');
        _locationController.text = locationText;
      }
    } catch (e) {
      _showError('Could not detect location. Please enter manually.');
    }

    if (mounted) setState(() => _isLoadingLocation = false);
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

              const SizedBox(height: 16),

              // Location
              const Text(
                'Location',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF003E3B),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDEDEDE)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your city or tap to detect',
                          hintStyle: TextStyle(color: Color(0xFFC3C3C3)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 16,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoadingLocation ? null : _detectLocation,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _isLoadingLocation
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF003E3B),
                                ),
                              )
                            : const Icon(
                                Icons.my_location,
                                color: Color(0xFF003E3B),
                                size: 24,
                              ),
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
