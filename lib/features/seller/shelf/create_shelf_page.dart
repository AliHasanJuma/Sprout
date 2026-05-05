import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/shelf_model.dart';
import '../widgets/seller_app_bar.dart';
import 'refine_shelf_page.dart';

class CreateShelfPage extends StatefulWidget {
  final ShelfModel? initial;
  final bool isEditing;

  const CreateShelfPage({super.key, this.initial, this.isEditing = false});

  @override
  State<CreateShelfPage> createState() => _CreateShelfPageState();
}

class _CreateShelfPageState extends State<CreateShelfPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final List<File> _photos = [];
  final List<String> _existingPhotoPaths = [];
  PriceType _priceType = PriceType.fixed;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _nameController.text = initial.name;
      _descriptionController.text = initial.description;
      _priceController.text = initial.price.toString();
      _priceType = initial.priceType;
      _existingPhotoPaths.addAll(initial.photoPaths);
    }
    // Focus name field on first load to match screenshot's lime-border focused state.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.initial == null) _nameFocus.requestFocus();
    });

    _nameController.addListener(_onChange);
    _descriptionController.addListener(_onChange);
    _priceController.addListener(_onChange);
  }

  void _onChange() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _photos.add(File(image.path)));
    }
  }

  bool get _canContinue {
    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim();
    final hasPhoto = _photos.isNotEmpty || _existingPhotoPaths.isNotEmpty;
    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText);
    return name.isNotEmpty &&
        desc.isNotEmpty &&
        hasPhoto &&
        price != null &&
        price > 0;
  }

  Future<void> _handleContinue() async {
    if (!_canContinue) return;

    final paths = [
      ..._existingPhotoPaths,
      ..._photos.map((f) => f.path),
    ];

    // ── FIX: Added storeId: '' to prevent compile errors ──
    // We will inject the REAL storeId in the RefineShelfPage before saving!
    final draft = (widget.initial ?? const ShelfModel(
      storeId: '', 
      name: '', 
      description: '', 
      price: 0
    )).copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      photoPaths: paths,
      priceType: _priceType,
      price: double.parse(_priceController.text.trim()),
    );

    if (widget.isEditing) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => RefineShelfPage(draft: draft, isEditing: true),
        ),
      );
      if (mounted && result == true) {
        Navigator.pop(context, true);
      }
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RefineShelfPage(draft: draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SellerAppBar(
        title: widget.isEditing ? 'Edit shelf' : 'Create a shelf',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const _FieldLabel('Product name'),
              const SizedBox(height: 8),
              _TextInput(
                controller: _nameController,
                focusNode: _nameFocus,
                hint: 'Enter your Product name',
              ),
              const SizedBox(height: 24),
              const _FieldLabel('Product description'),
              const SizedBox(height: 8),
              _TextInput(
                controller: _descriptionController,
                hint: 'Enter a Product Description',
              ),
              const SizedBox(height: 24),
              const _FieldLabel('product photos'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: 153,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDEDEDE)),
                    color: Colors.white,
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
                      const Text(
                        'Upload a photo',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_photos.isNotEmpty || _existingPhotoPaths.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 64,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final path in _existingPhotoPaths)
                        _PhotoThumb(file: File(path)),
                      for (final file in _photos) _PhotoThumb(file: file),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const _FieldLabel('Set a price'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PriceRadio(
                      selected: _priceType == PriceType.fixed,
                      label: 'Fixed price',
                      onTap: () => setState(() => _priceType = PriceType.fixed),
                    ),
                  ),
                  Expanded(
                    child: _PriceRadio(
                      selected: _priceType == PriceType.startingAt,
                      label: 'Starting at',
                      onTap: () => setState(() => _priceType = PriceType.startingAt),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _PriceInput(controller: _priceController),
              const SizedBox(height: 48),
              CustomButton(
                text: widget.isEditing ? 'Continue' : 'Continue',
                onPressed: _canContinue ? _handleContinue : null,
                backgroundColor: _canContinue
                    ? AppColors.primary
                    : const Color(0xFFE5E5E5),
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

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.secondary,
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hint;

  const _TextInput({
    required this.controller,
    required this.hint,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'SF Pro Display',
          color: Color(0xFFC3C3C3),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDEDEDE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }
}

class _PhotoThumb extends StatelessWidget {
  final File file;
  const _PhotoThumb({required this.file});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(file, width: 64, height: 64, fit: BoxFit.cover),
      ),
    );
  }
}

class _PriceRadio extends StatelessWidget {
  final bool selected;
  final String label;
  final VoidCallback onTap;

  const _PriceRadio({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFC3C3C3),
                width: 2,
              ),
            ),
            child: selected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.black : const Color(0xFF9F9F9F),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceInput extends StatelessWidget {
  final TextEditingController controller;
  const _PriceInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
      ],
      style: const TextStyle(
        fontFamily: 'SF Pro Display',
        fontSize: 14,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: 'Enter a number',
        hintStyle: const TextStyle(
          fontFamily: 'SF Pro Display',
          color: Color(0xFFC3C3C3),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 16, right: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1.0,
            child: Text(
              'BD',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDEDEDE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }
}