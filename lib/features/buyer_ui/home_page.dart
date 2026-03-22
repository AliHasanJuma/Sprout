import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../shared/widgets/search_bar.dart';
import '../../screens/profile_page.dart';
import '../../screens/category_page.dart';
import '../../screens/store_page.dart';
import '../../screens/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Banner page controller for the scrollable carousel
  late final PageController _pageController;
  int _bannerPage = 0;

  // Firebase current user
  User? get _user => FirebaseAuth.instance.currentUser;

  // Extract first name from display name; fallback to 'there'
  String get _firstName {
    if (_user?.displayName != null) {
      return _user!.displayName!.split(' ').first;
    }
    return 'there';
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Category data ──────────────────────────────────────────────────────────
  static const List<_Category> _categories = [
    _Category('Sweet &\nBaking','assets/images/category/Baking.png'),
    _Category('Gifts','assets/images/category/gift.png'),
    _Category('Perfumes','assets/images/category/perfume.png'),
    _Category('Home\nCooking','assets/images/category/home-cooking.png'),
    _Category('Crafts &\nHome Decor','assets/images/category/Crafts.png'),
    _Category('Fashion','assets/images/category/fastion.png'),
  ];

  // ── Near-me store data ─────────────────────────────────────────────────────
  static const List<_Store> _stores = [
    _Store(
      name: 'Honey & Thyme',
      rating: 3.0,
      imagePath: 'assets/images/home page widgets/0001.png',
    ),
    _Store(
      name: 'Sweet Bloom',
      rating: 3.0,
      imagePath: 'assets/images/home page widgets/0001.png',
    ),
    _Store(
      name: 'Craft Corner',
      rating: 3.5,
      imagePath: 'assets/images/home page widgets/0001.png',
    ),
    _Store(
      name: 'Aroma Studio',
      rating: 3.5,
      imagePath: 'assets/images/home page widgets/0001.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Lime-green SVG wave header with floating search bar
            _buildWaveHeader(),

            // 24px accounts for the search bar half below the wave +
            // 16px gap before the Categories title
            const SizedBox(height: 40),

            // 2. Categories
            _buildCategories(),

            const SizedBox(height: 28),

            // 4. Banner / carousel card
            _buildBanner(),

            const SizedBox(height: 28),

            // 5. Near me
            _buildNearMe(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── 1. WAVE HEADER ─────────────────────────────────────────────────────────
  // Uses bowdesign.svg as the lime-green wave background.
  // The search bar is floated at the wave boundary via Positioned(bottom: -24),
  // so it sits half on green and half on white.
  Widget _buildWaveHeader() {
    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── SVG wave background ──────────────────────────────────────────
          SvgPicture.asset(
            'assets/Essentials/bowdesign.svg',
            width: double.infinity,
            height: 200,
            fit: BoxFit.fill,
            // Override baked-in #daf64f with the Figma spec colour
            colorFilter: const ColorFilter.mode(
              Color(0xFFCDEB45),
              BlendMode.srcIn,
            ),
          ),

          // ── Header content: logo + welcome text + profile avatar ─────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8,
                left: 24,
                right: 24,
                bottom: 56, // keeps content above the wave curve
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo + welcome message grouped on the left
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/logo/logoBlack_fullsize.png',
                        width: 100,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Wellcome back, $_firstName',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  // Profile avatar — navigates to ProfilePage
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/icons/Profile_picture.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Floating search bar — straddles the wave / white boundary ────
          // Tapping navigates to SearchPage
          Positioned(
            bottom: -8, // half of 48px height → centered on the boundary
            left: 24,
            right: 24,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              ),
              child: const AbsorbPointer(
                child: CustomSearchBar(hintText: 'Search for anything'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. CATEGORIES ──────────────────────────────────────────────────────────
  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Categories',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Horizontal scrollable row — 65×65 image + label below
        SizedBox(
          height: 104, // 65 image + 6 gap + ~28 label (2 lines × 10px + leading)
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryItem(_categories[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(_Category cat) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CategoryPage()),
      ),
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            // 65×65 rounded image; grey fallback until assets are added
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                cat.imagePath,
                width: 65,
                height: 65,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              cat.label,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 10,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── 4. BANNER / CAROUSEL ───────────────────────────────────────────────────
  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Horizontally scrollable PageView carousel
          SizedBox(
            height: 170,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 3,
              onPageChanged: (page) => setState(() => _bannerPage = page),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryPage()),
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7E7).withValues(alpha: 0.49),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/home page widgets/0001.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFFDDE8B0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Pagination dots — animate as user swipes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final isActive = i == _bannerPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: isActive ? Colors.black : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── 5. NEAR ME ─────────────────────────────────────────────────────────────
  Widget _buildNearMe() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Near me',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 140, // 80 image + 8 gap + ~12 name + 4 gap + 12 stars
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            itemCount: _stores.length,
            itemBuilder: (context, index) {
              return _buildStoreCard(_stores[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoreCard(_Store store) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StorePage(storeName: store.name),
        ),
      ),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Store image placeholder (80×80, rounded 12, grey)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const SizedBox(height: 8),

            // Store name — centered
            Text(
              store.name,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Star rating — centered
            Center(child: _buildStars(store.rating)),
          ],
        ),
      ),
    );
  }

  /// Builds a row of 5 star icons supporting full and half stars.
  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final full = i < rating.floor();
        final half = !full && (rating - i) >= 0.5 && (rating - i) < 1.0;
        return Icon(
          full
              ? Icons.star
              : half
                  ? Icons.star_half
                  : Icons.star_border,
          size: 12,
          color: Colors.amber,
        );
      }),
    );
  }
}

// ── Simple immutable category model ─────────────────────────────────────────
class _Category {
  final String label;
  final String imagePath;
  const _Category(this.label, this.imagePath);
}

// ── Simple immutable store model ─────────────────────────────────────────────
class _Store {
  final String name;
  final double rating;
  final String imagePath;
  const _Store({
    required this.name,
    required this.rating,
    required this.imagePath,
  });
}
