import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../models/store_model.dart';
import '../services/seller_service.dart';
import '../widgets/seller_app_bar.dart';
import 'customize_store_page.dart';

class ChooseCategoryPage extends StatefulWidget {
  final StoreModel draft;
  final bool isEditing;

  const ChooseCategoryPage({
    super.key,
    required this.draft,
    this.isEditing = false,
  });

  @override
  State<ChooseCategoryPage> createState() => _ChooseCategoryPageState();
}

class _ChooseCategoryPageState extends State<ChooseCategoryPage> {
  String? _selectedCategory;

  final List<String> _categories = [
    'Sweets and baking',
    'Home cooking',
    'Gifts',
    'Crafts and Home decor',
    'Perfumes',
    'Fashion',
  ];

  @override
  void initState() {
    super.initState();
    // If they go "Back" to this page, it remembers what they previously selected
    _selectedCategory = widget.draft.category;
  }

  Future<void> _handleContinue() async {
    // ── 1. VALIDATION: FORCE SELECTION ──
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category to continue.')),
      );
      return;
    }

    // ── 2. LOCAL RAM SAVE ──
    // This updates the temporary draft object without touching Firebase
    final updated = widget.draft.copyWith(category: _selectedCategory);

    // ── 3. EDIT MODE OVERRIDE (For later) ──
    // If the seller is editing an already existing store from their dashboard, 
    // this pushes the change to Firebase immediately.
    if (widget.isEditing) {
      await SellerService().updateStore(updated);
      if (mounted) Navigator.pop(context, updated);
      return;
    }

    // ── 4. PASS DRAFT TO NEXT SCREEN ──
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CustomizeStorePage(draft: updated)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selectedCategory != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SellerAppBar(
        title: widget.isEditing ? 'Edit category' : 'Choose a category',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Text(
                'What do you do?',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 24),
              ..._categories.asMap().entries.map((entry) {
                final index = entry.key;
                final categoryName = entry.value;
                final isSelected = _selectedCategory == categoryName;

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          // Toggles selection off if tapped again, otherwise selects the new one
                          _selectedCategory = isSelected ? null : categoryName;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(0xFFC3C3C3),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                categoryName,
                                style: TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: isSelected
                                      ? Colors.black
                                      : const Color(0xFF9F9F9F),
                                ),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFFC3C3C3),
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 14,
                                        height: 14,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (index < _categories.length - 1)
                      const SizedBox(height: 16),
                  ],
                );
              }),
              const SizedBox(height: 48),
              CustomButton(
                text: widget.isEditing ? 'Save changes' : 'Continue',
                onPressed: canContinue ? _handleContinue : null,
                backgroundColor: canContinue
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