import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; // ── NEW IMPORT ──

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

  // ── UPDATED: SECURE LOCAL SAVING ──
  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // 1. Get the app's safe document directory
      final directory = await getApplicationDocumentsDirectory();
      
      // 2. Create a unique file name so images don't overwrite each other
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${isLogo ? 'logo' : 'banner'}.jpg';
      
      // 3. Copy the file from the temporary cache to the safe directory
      final savedImage = await File(pickedFile.path).copy('${directory.path}/$fileName');

      // 4. Update the UI
      setState(() {
        if (isLogo) {
          _logoImage = savedImage;
        } else {
          _bannerImage = savedImage;
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
        const SnackBar(content: Text('Please upload both a logo and a banner to make your shop look great!')),
      );
      return;
    }

    final logoPath = _logoImage?.path ?? _existingLogoPath;
    final bannerPath = _bannerImage?.path ?? _existingBannerPath;

    // Save the safe local file paths to the draft in RAM
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

  // Prevents crashes by checking if the image is from the web or the local phone
  Widget _buildImagePreview(File? newFile, String? existingPath, double width, double height) {
    if (newFile != null) {
      return Image.file(newFile, width: width, height: height, fit: BoxFit.cover);
    }
    if (existingPath != null) {
      if (existingPath.startsWith('http')) {
        return Image.network(existingPath, width: width, height: height, fit: BoxFit.cover);
      } else {
        return Image.file(File(existingPath), width: width, height: height, fit: BoxFit.cover);
      }
    }
    return const SizedBox.shrink(); 
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
                    child: _buildImagePreview(_logoImage, _existingLogoPath, 80, 80),
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
                    child: _buildImagePreview(_bannerImage, _existingBannerPath, double.infinity, 100),
                  ),
                ),
              ],
              const SizedBox(height: 48),
              CustomButton(
                text: widget.isEditing ? 'Save changes' : 'Continue',
                onPressed: _handleContinue,
                backgroundColor: _canContinue ? AppColors.primary : const Color(0xFFE5E5E5),
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