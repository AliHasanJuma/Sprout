import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
  String? _selectedDefaultBanner;

  static const _defaultBanners = [
    'assets/defualt banners/dv001.png',
    'assets/defualt banners/dv002.png',
    'assets/defualt banners/dv003.png',
    'assets/defualt banners/dv004.png',
  ];

  @override
  void initState() {
    super.initState();
    _existingLogoPath = widget.draft.logoPath;
    final existingBanner = widget.draft.bannerPath;
    if (existingBanner != null && _defaultBanners.contains(existingBanner)) {
      _selectedDefaultBanner = existingBanner;
    } else {
      _existingBannerPath = existingBanner;
    }
  }

  Future<void> _pickImage(bool isLogo) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${isLogo ? 'logo' : 'banner'}.jpg';
      final savedImage = await File(pickedFile.path).copy('${directory.path}/$fileName');

      setState(() {
        if (isLogo) {
          _logoImage = savedImage;
        } else {
          _bannerImage = savedImage;
          _selectedDefaultBanner = null;
        }
      });
    }
  }

  Future<void> _chooseDefaultBanner() async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => _DefaultBannerSelectionPage(
          banners: _defaultBanners,
          selectedBanner: _selectedDefaultBanner,
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedDefaultBanner = selected;
        _bannerImage = null;
        _existingBannerPath = null;
      });
    }
  }

  bool get _canContinue {
    final hasLogo = _logoImage != null || _existingLogoPath != null;
    final hasBanner = _bannerImage != null || _existingBannerPath != null || _selectedDefaultBanner != null;
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
    final bannerPath = _selectedDefaultBanner ?? _bannerImage?.path ?? _existingBannerPath;

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

  Widget _buildImagePreview(File? newFile, String? existingPath, double width, double height) {
    if (newFile != null) {
      return Image.file(newFile, width: width, height: height, fit: BoxFit.cover);
    }
    if (existingPath != null) {
      if (existingPath.startsWith('http')) {
        return Image.network(existingPath, width: width, height: height, fit: BoxFit.cover);
      } else if (_defaultBanners.contains(existingPath)) {
        return Image.asset(existingPath, width: width, height: height, fit: BoxFit.cover);
      } else {
        return Image.file(File(existingPath), width: width, height: height, fit: BoxFit.cover);
      }
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final hasBannerPreview = _bannerImage != null || _existingBannerPath != null || _selectedDefaultBanner != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SellerAppBar(
        title: widget.isEditing ? 'Edit store logo and banner' : 'Customize your Store',
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
              Row(
                children: [
                  Expanded(
                    child: _UploadButton(
                      hasImage: _bannerImage != null || (_existingBannerPath != null),
                      onTap: () => _pickImage(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ChooseDefaultButton(
                      hasSelection: _selectedDefaultBanner != null,
                      onTap: _chooseDefaultBanner,
                    ),
                  ),
                ],
              ),
              if (hasBannerPreview) ...[
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
                    child: _buildImagePreview(
                      _bannerImage,
                      _selectedDefaultBanner ?? _existingBannerPath,
                      double.infinity,
                      100,
                    ),
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

class _DefaultBannerSelectionPage extends StatefulWidget {
  final List<String> banners;
  final String? selectedBanner;

  const _DefaultBannerSelectionPage({
    required this.banners,
    this.selectedBanner,
  });

  @override
  State<_DefaultBannerSelectionPage> createState() => _DefaultBannerSelectionPageState();
}

class _DefaultBannerSelectionPageState extends State<_DefaultBannerSelectionPage> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedBanner;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SellerAppBar(title: 'Customize your Store'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 4, 32, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose a default',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 24),
              ...widget.banners.map((banner) {
                final isSelected = _selected == banner;
                return GestureDetector(
                  onTap: () => Navigator.pop(context, banner),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.grey.shade400, width: 2.5)
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isSelected ? 10 : 12),
                      child: Image.asset(
                        banner,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }),
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

class _ChooseDefaultButton extends StatelessWidget {
  final bool hasSelection;
  final VoidCallback onTap;

  const _ChooseDefaultButton({required this.hasSelection, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/UI icons package/SVG/File/Note_Search.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(AppColors.secondary, BlendMode.srcIn),
            ),
            const SizedBox(width: 8),
            Text(
              hasSelection ? 'Default selected' : 'Choose a default',
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
