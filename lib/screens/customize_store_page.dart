import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';

class CustomizeStorePage extends StatefulWidget {
  const CustomizeStorePage({super.key});

  @override
  State<CustomizeStorePage> createState() => _CustomizeStorePageState();
}

class _CustomizeStorePageState extends State<CustomizeStorePage> {
  File? _logoImage;
  File? _bannerImage;
  bool _isLoading = false;

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
    );
    
    if (image != null) {
      setState(() {
        if (isLogo) {
          _logoImage = File(image.path);
        } else {
          _bannerImage = File(image.path);
        }
      });
    }
  }

  Future<void> _handleContinue() async {
    if (_logoImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a store logo')),
      );
      return;
    }

    if (_bannerImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a store banner')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Upload images to Firebase Storage and save URLs to Firestore
    // This is where your friends will implement the actual upload logic
    
    print('Logo image: ${_logoImage?.path}');
    print('Banner image: ${_bannerImage?.path}');
    
    // Navigate to next screen
    // Navigator.push(context, MaterialPageRoute(builder: (_) => NextScreen()));
    
    setState(() => _isLoading = false);
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
          'Customize your Store',
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
              
              // Upload Store Logo Section
              const Text(
                'Upload store logo',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF003E3B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This logo will represent your shop across the app, like your storefront or chats.',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9F9F9F),
                ),
              ),
              const SizedBox(height: 16),
              
              // Logo Upload Button
              GestureDetector(
                onTap: () => _pickImage(true),
                child: Container(
                  width: 153,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _logoImage == null ? Icons.cloud_upload_outlined : Icons.check_circle,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _logoImage == null ? 'Upload a photo' : 'Photo selected',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Show logo preview if selected
              if (_logoImage != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _logoImage!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 48),
              
              // Upload Store Banner Section
              const Text(
                'Upload store Banner',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF003E3B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your banner defines the atmosphere of your shop.\nUse an image that captures your brand\'s style.',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9F9F9F),
                ),
              ),
              const SizedBox(height: 16),
              
              // Banner Upload Button
              GestureDetector(
                onTap: () => _pickImage(false),
                child: Container(
                  width: 153,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _bannerImage == null ? Icons.cloud_upload_outlined : Icons.check_circle,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _bannerImage == null ? 'Upload a photo' : 'Photo selected',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Show banner preview if selected
              if (_bannerImage != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _bannerImage!,
                      width: double.infinity,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 48),
              
              // Continue Button
              CustomButton(
                text: _isLoading ? 'Uploading...' : 'Continue',
                onPressed: _isLoading ? null : _handleContinue,
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