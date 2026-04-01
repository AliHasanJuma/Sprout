import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared/widgets/search_bar.dart';
import '../../screens/profile_page.dart';
import '../../screens/store_page.dart';
import '../../screens/search_page.dart';
import '../../data/temp_data.dart';
import '../../providers/cart_provider.dart';
import '../../pages/cart_page.dart';
import '../../pages/categories/category_stores_page.dart';
import '../../pages/categories/special_categories/new_stores_page.dart';
import '../../pages/categories/special_categories/featured_stores_page.dart';
import '../../pages/categories/special_categories/top_rated_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController;
  int _bannerPage = 0;
  final CartProvider _cart = CartProvider();

  User? get _user => FirebaseAuth.instance.currentUser;

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
    _cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  // ── Category data ──
  static const List<_Category> _categories = [
    _Category('Sweet &\nBaking', 'assets/images/category/Baking.png'),
    _Category('Gifts', 'assets/images/category/gift.png'),
    _Category('Perfumes', 'assets/images/category/perfume.png'),
    _Category('Home\nCooking', 'assets/images/category/home-cooking.png'),
    _Category('Crafts &\nHome Decor', 'assets/images/category/Crafts.png'),
    _Category('Fashion', 'assets/images/category/fastion.png'),
  ];

  // ── Near-me store data ──
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

  // ── Banner destinations (special categories) ──
  static final List<Widget> _bannerPages = [
    const NewStoresPage(),
    const FeaturedStoresPage(),
    const TopRatedPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWaveHeader(),
            const SizedBox(height: 40),
            _buildCategories(),
            const SizedBox(height: 28),
            _buildBanner(),
            const SizedBox(height: 28),
            _buildNearMe(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveHeader() {
    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: _BowClipper(),
            child: Container(
              width: double.infinity,
              height: 200,
              color: const Color(0xFFCDEB45),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 8, left: 24, right: 24, bottom: 56),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  Row(
                    children: [
                      // Cart icon — only visible when cart has items
                      if (_cart.totalItemCount > 0)
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CartPage()),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Image.asset(
                                  'assets/UI icons package/PNG/Black/Interface/Shopping_Cart_01.png',
                                  width: 26,
                                  height: 26,
                                  color: const Color(0xFF003E3B),
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                                Positioned(
                                  top: -6,
                                  right: -8,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '${_cart.totalItemCount}',
                                      style: const TextStyle(
                                        fontFamily: 'SF Pro Display',
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Profile avatar
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
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -8,
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
        SizedBox(
          height: 104,
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
        MaterialPageRoute(
          builder: (_) => CategoryStoresPage(categoryName: cat.label),
        ),
      ),
      child: Container(
        width: 78,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                cat.imagePath,
                width: 65,
                height: 65,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
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

  Widget _buildBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SizedBox(
            height: 170,
            child: PageView.builder(
              controller: _pageController,
              itemCount: 3,
              onPageChanged: (page) => setState(() => _bannerPage = page),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => _bannerPages[index]),
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
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFDDE8B0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
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
          height: 140,
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
    final tempStore = tempStores.firstWhere(
      (s) => s.name == store.name,
      orElse: () => tempStores.first,
    );

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StorePage(store: tempStore),
        ),
      ),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 8),
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
            Center(child: _buildStars(store.rating)),
          ],
        ),
      ),
    );
  }

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

class _BowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double svgHeight = 274.0;
    const double svgPeakDepth = 51.8;
    final double controlY =
        size.height - (size.height * (svgPeakDepth / svgHeight) * 2);

    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2, controlY,
      size.width, size.height,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_BowClipper oldClipper) => false;
}

class _Category {
  final String label;
  final String imagePath;
  const _Category(this.label, this.imagePath);
}

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
