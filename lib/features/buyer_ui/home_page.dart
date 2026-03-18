import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/search_bar.dart';
import '../../shared/widgets/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ADD ScrollController and index tracking
  final ScrollController _categoryScrollController = ScrollController();
  int _currentCategoryIndex = 0;
  final int _totalCategories = 10;
  final double _itemWidth = 260; // Width of each category button
  final double _spacing = 12; // margin.only(right: 12)
  
  // Get current user
  User? get _user => FirebaseAuth.instance.currentUser;
  
  // Extract first name from display name
  String get _firstName {
    if (_user?.displayName != null) {
      return _user!.displayName!.split(' ').first;
    }
    return 'there';
  }

  @override
  void initState() {
    super.initState();
    _categoryScrollController.addListener(_updateCategoryIndex);
  }

  void _updateCategoryIndex() {
    // Calculate which category is most visible based on scroll position
    double scrollPosition = _categoryScrollController.offset;
    int newIndex = ((scrollPosition + 32) / (_itemWidth + _spacing)).round();
    
    // Clamp between 0 and total-1
    newIndex = newIndex.clamp(0, _totalCategories - 1);
    
    if (newIndex != _currentCategoryIndex) {
      setState(() {
        _currentCategoryIndex = newIndex;
      });
    }
  }

  @override
  void dispose() {
    _categoryScrollController.removeListener(_updateCategoryIndex);
    _categoryScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NEON TOP SECTION
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(top: 48, left: 32, right: 32, bottom: 32), // Increased bottom padding
              child: Column(
                children: [
                  // Top row with logo and profile icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo (top left)
                      Image.asset(
                        'assets/logo/logodark_green.png',
                        width: 100,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                      // Profile icon (top right)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          image: DecorationImage(
                            image: AssetImage('assets/icons/Profile_picture.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Welcome back text - added here
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Welcome back, $_firstName',
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16), // Space between text and search bar
                  
                  // Search bar
                  const CustomSearchBar(),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // RANDOM PRODUCTS SECTION
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                'Recommended for you',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Horizontal list of product images
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    height: 64,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFFDEDEDE),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Item ${index + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // CATEGORY SCROLLING BUTTONS
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                'Categories',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Horizontal scrollable category buttons
            SizedBox(
              height: 140,
              child: ListView.builder(
                controller: _categoryScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                itemCount: _totalCategories,
                itemBuilder: (context, index) {
                  return Container(
                    width: _itemWidth,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Category ${index + 1}',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Scroll dots indicator
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_totalCategories, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentCategoryIndex 
                          ? AppColors.primary 
                          : Colors.grey.withValues(alpha: 0.3),
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // NEAR ME SECTION
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                'Near Me',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Horizontal list of sellers
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Container(
                    width: 96,
                    margin: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        // Seller image
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: Color(0xFFDEDEDE),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '👤',
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Seller name
                        Text(
                          'Seller ${index + 1}',
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '4.${index + 5}',
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 100), // Space for navbar
          ],
        ),
      ),
    );
  }
}