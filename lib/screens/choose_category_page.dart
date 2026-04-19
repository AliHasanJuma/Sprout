import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'customize_store_page.dart';

class ChooseCategoryPage extends StatefulWidget {
  const ChooseCategoryPage({super.key});

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

  void _handleContinue() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    // TODO: Save category to Firestore and navigate to next step
    print('Selected category: $_selectedCategory');
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Category selected: $_selectedCategory')),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CustomizeStorePage()),
    );
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
          'Choose a category',
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
              
              // Question text
              const Text(
                'What do you do?',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF003E3B),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Category options
              ..._categories.asMap().entries.map((entry) {
                final index = entry.key;
                final categoryName = entry.value;
                final isSelected = _selectedCategory == categoryName;
                
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = categoryName;
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
                            // Category name
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
                            // Radio circle
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
                      const SizedBox(height: 12),
                  ],
                );
              }),
              
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