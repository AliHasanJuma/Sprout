import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/store_model.dart';
import '../services/seller_service.dart';
import '../widgets/seller_app_bar.dart';
import 'store_location_page.dart';

class CustomizeStorePage extends StatefulWidget {
  final StoreModel draft;
  final bool isEditing;

  const CustomizeStorePage({
    super.key,
    required this.draft,
    this.isEditing = false,
  });

  @override
  State<CustomizeStorePage> createState() => _CustomizeStorePageState();
}

class _CustomizeStorePageState extends State<CustomizeStorePage> {
  File? _logoImage;
  File? _bannerImage;

  String? _existingLogoPath;
  String? _existingBannerPath;

  @override
  void initState() {
    super.initState();
    _existingLogoPath = widget.draft.logoPath;
    _existingBannerPath = widget.draft.bannerPath;
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

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

  bool get _canContinue {
    final hasLogo = _logoImage != null || _existingLogoPath != null;
    final hasBanner = _bannerImage != null || _existingBannerPath != null;
    return hasLogo && hasBanner;
  }

  Future<void> _handleContinue() async {
    if (!_canContinue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both a logo and banner')),
      );
      return;
    }

    final logoPath = _logoImage?.path ?? _existingLogoPath;
    final bannerPath = _bannerImage?.path ?? _existingBannerPath;

    final updated = widget.draft.copyWith(
      logoPath: logoPath,
      bannerPath: bannerPath,
    );

    if (widget.isEditing) {
      await SellerService().updateStore(updated);
      if (mounted) Navigator.pop(context, updated);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StoreLocationPage(draft: updated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SellerAppBar(
        title: widget.isEditing
            ? 'Edit store logo and banner'
            : 'Customize your Store',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Text(
                'Upload store logo',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
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
              _UploadButton(
                hasImage: _logoImage != null || _existingLogoPath != null,
                onTap: () => _pickImage(true),
              ),
              if (_logoImage != null || _existingLogoPath != null) ...[
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
                    child: _logoImage != null
                        ? Image.file(
                            _logoImage!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_existingLogoPath!),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ],
              const SizedBox(height: 48),
              const Text(
                'Upload store Banner',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
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
              _UploadButton(
                hasImage: _bannerImage != null || _existingBannerPath != null,
                onTap: () => _pickImage(false),
              ),
              if (_bannerImage != null || _existingBannerPath != null) ...[
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
                    child: _bannerImage != null
                        ? Image.file(
                            _bannerImage!,
                            width: double.infinity,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(_existingBannerPath!),
                            width: double.infinity,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ],
              const SizedBox(height: 48),
              CustomButton(
                text: widget.isEditing ? 'Save changes' : 'Continue',
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

class _UploadButton extends StatelessWidget {
  final bool hasImage;
  final VoidCallback onTap;

  const _UploadButton({required this.hasImage, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            Image.asset(
              'assets/UI icons package/PNG/Black/File/File_Upload.png',
              width: 20,
              height: 20,
              color: AppColors.secondary,
            ),
            const SizedBox(width: 8),
            Text(
              hasImage ? 'Photo selected' : 'Upload a photo',
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
    );
  }
}
