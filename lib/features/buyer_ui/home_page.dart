import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'dart:math' as math; 
import 'dart:async'; // ── ADDED FOR FIREBASE ALARM CLOCK ──

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

  // ── NEW: Listeners and State ──
  StreamSubscription<User?>? _authSubscription;
  String _userName = "there";
  List<Map<String, dynamic>> _nearMeStores = [];
  bool _isLoadingStores = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _cart.addListener(_onCartChanged);
    
    // ── THE FIX: Wait for Firebase to securely load the user from memory ──
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && mounted) {
        // Now that we are 100% sure the user is loaded, fetch the data!
        _loadInitialData(user.uid);
      } else if (user == null && mounted) {
        // Handle case where user might be completely logged out
        setState(() => _isLoadingStores = false);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel(); // Always clean up your listeners!
    _cart.removeListener(_onCartChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  // ── NEW: One-Time Fetch Function that runs exactly when the user is ready ──
  Future<void> _loadInitialData(String uid) async {
    if (!mounted) return;
    setState(() => _isLoadingStores = true); // Ensure loading spinner is showing

    try {
      // 1. Fetch User Data (Name and Location)
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      
      double userLat = 26.0667; 
      double userLon = 50.5577;

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;
        _userName = userData['firstName'] ?? "there";
        userLat = (userData['latitude'] ?? userLat).toDouble();
        userLon = (userData['longitude'] ?? userLon).toDouble();
      }

      // 2. Fetch Stores exactly once
      final storeSnap = await FirebaseFirestore.instance.collection('stores').get();
      List<Map<String, dynamic>> sortedStores = [];

      for (var doc in storeSnap.docs) {
        final data = doc.data();
        if (data['ownerId'] == uid) continue; // Hide the user's own shop
        final storeLat = (data['latitude'] ?? 0.0).toDouble();
        final storeLon = (data['longitude'] ?? 0.0).toDouble();

        final calculatedDistance = _calculateDistance(userLat, userLon, storeLat, storeLon);

        data['realDistanceKm'] = calculatedDistance;
        data['docId'] = doc.id;

        sortedStores.add(data);
      }

      // Sort the list based on distance (lowest first)
      sortedStores.sort((a, b) => (a['realDistanceKm'] as double).compareTo(b['realDistanceKm'] as double));

      // 3. Update the UI permanently 
      if (mounted) {
        setState(() {
          _nearMeStores = sortedStores;
          _isLoadingStores = false;
        });
      }
    } catch (e) {
      print("Error loading home page data: $e");
      if (mounted) {
        setState(() => _isLoadingStores = false);
      }
    }
  }

  static const List<_Category> _categories = [
    _Category('Sweet &\nBaking', 'assets/images/category/Baking.png'),
    _Category('Gifts', 'assets/images/category/gift.png'),
    _Category('Perfumes', 'assets/images/category/perfume.png'),
    _Category('Home\nCooking', 'assets/images/category/home-cooking.png'),
    _Category('Crafts &\nHome Decor', 'assets/images/category/Crafts.png'),
    _Category('Fashion', 'assets/images/category/fastion.png'),
  ];

  static final List<Widget> _bannerPages = [
    const NewStoresPage(),
    const FeaturedStoresPage(),
    const TopRatedPage(),
  ];

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; 
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
        
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c; 
  }

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
              padding: const EdgeInsets.only(top: 8, left: 24, right: 24, bottom: 56),
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
                        'Welcome back, $_userName', // Guaranteed to only draw once data is ready
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
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
            style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 104,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            itemCount: _categories.length,
            itemBuilder: (context, index) => _buildCategoryItem(_categories[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(_Category cat) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CategoryStoresPage(categoryName: cat.label)),
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
                width: 65, height: 65, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 65, height: 65, color: const Color(0xFFEEEEEE)),
              ),
            ),
            const SizedBox(height: 6),
            Text(cat.label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center, maxLines: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Column(
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
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7E7).withValues(alpha: 0.49),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/home page widgets/0001.png',
                    fit: BoxFit.cover, width: double.infinity,
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
            style: TextStyle(fontFamily: 'SF Pro Display', fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: _isLoadingStores
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF003E3B)))
              : _nearMeStores.isEmpty
                  ? const Center(child: Text("No stores found", style: TextStyle(color: Color(0xFF9F9F9F))))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      itemCount: _nearMeStores.length,
                      itemBuilder: (context, index) {
                        return _buildStoreCardFromFirebase(_nearMeStores[index], _nearMeStores[index]['docId']);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStoreCardFromFirebase(Map<String, dynamic> data, String docId) {
    final distance = data['realDistanceKm'] ?? 0.0;

    final firebaseStore = Store(
      id: docId, 
      name: data['name'] ?? 'Shop',
      description: data['description'] ?? '',
      imagePath: data['imageUrl'] ?? 'https://via.placeholder.com/80',
      logoPath: data['logoUrl'] ?? 'https://via.placeholder.com/80',
      rating: (data['rating'] ?? 0.0).toDouble(),
      category: data['category'] ?? 'General',
      distanceKm: distance, 
      products: [], 
    );

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StorePage(store: firebaseStore)),
      ),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFDEDEDE),
                  width: 0.7,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  data['logoUrl'] ?? 'https://via.placeholder.com/80',
                  width: 80, height: 80, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: const Color(0xFFD9D9D9)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data['name'] ?? 'Shop',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            _buildStars((data['rating'] ?? 0.0).toDouble()),
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
          full ? Icons.star : half ? Icons.star_half : Icons.star_border,
          size: 12, color: Colors.amber,
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
    final double controlY = size.height - (size.height * (svgPeakDepth / svgHeight) * 2);
    final path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, controlY, size.width, size.height);
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