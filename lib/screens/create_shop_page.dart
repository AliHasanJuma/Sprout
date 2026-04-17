import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_textfield.dart';

class CreateShopPage extends StatefulWidget {
  const CreateShopPage({super.key});

  @override
  State<CreateShopPage> createState() => _CreateShopPageState();
}

class _CreateShopPageState extends State<CreateShopPage> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final shopName = _shopNameController.text.trim();
    final bio = _bioController.text.trim();

    if (shopName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your shop name')),
      );
      return;
    }

    if (bio.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a short bio')),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the terms & conditions')),
      );
      return;
    }

    // TODO: Save shop data to Firestore
    print('Shop Name: $shopName');
    print('Bio: $bio');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shop created successfully!')),
    );
    
    // Navigate back or to shop dashboard
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Create your shop',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            color: Color(0xFF003E3B),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              
              // Shop Name Field
              CustomTextField(
                label: 'Shop Name',
                hintText: 'Enter your shop name',
                controller: _shopNameController,
              ),
              
              const SizedBox(height: 16),
              
              // Short Bio Field
              CustomTextField(
                label: 'Short Bio',
                hintText: 'Enter a short and catchy Bio',
                controller: _bioController,
              ),
              
              const SizedBox(height: 32),
              
              // Terms & Conditions Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                      checkColor: AppColors.secondary,
                      side: const BorderSide(color: Color(0xFFDEDEDE), width: 1.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Agree on terms & conditions',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF003E3B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            text: 'to know more visit the ',
                            style: const TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFC3C3C3),
                            ),
                            children: [
                              TextSpan(
                                text: 'sprout terms page',
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF9F9F9F),
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO: Navigate to terms page
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Terms page coming soon!')),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Continue Button
              CustomButton(
                text: 'Continue',
                onPressed: _handleContinue,
                backgroundColor: AppColors.primary,
                textColor: Colors.black,
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}