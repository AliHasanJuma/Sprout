// TODO: Replace with Firebase
import 'package:flutter/material.dart';
import '../data/temp_data.dart';
import 'inner_chat_page.dart';

class StorePage extends StatefulWidget {
  final Store store;

  const StorePage({super.key, required this.store});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  bool _isFavourite = false;

  @override
  void initState() {
    super.initState();
    _isFavourite =
        tempFavourites.any((f) => f.storeId == widget.store.id);
  }

  void _toggleFavourite() {
    setState(() {
      if (_isFavourite) {
        tempFavourites.removeWhere((f) => f.storeId == widget.store.id);
        _isFavourite = false;
      } else {
        tempFavourites.add(FavouriteItem(
          storeId: widget.store.id,
          storeName: widget.store.name,
          imagePath: widget.store.imagePath,
          rating: widget.store.rating,
        ));
        _isFavourite = true;
      }
    });
  }

  /// Map category text to a category image asset path
  String _getCategoryImage(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('baking') || lower.contains('sweet')) {
      return 'assets/images/category/Baking.png';
    } else if (lower.contains('gift')) {
      return 'assets/images/category/gift.png';
    } else if (lower.contains('perfume')) {
      return 'assets/images/category/perfume.png';
    } else if (lower.contains('cooking') || lower.contains('home')) {
      return 'assets/images/category/home-cooking.png';
    } else if (lower.contains('craft') || lower.contains('decor')) {
      return 'assets/images/category/Crafts.png';
    } else if (lower.contains('fashion')) {
      return 'assets/images/category/fastion.png';
    }
    return 'assets/images/category/home-cooking.png';
  }

  /// Clean category name for display (remove newlines)
  String _getCategoryName(String category) {
    return category.replaceAll('\n', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Wave header with back/heart buttons and store logo ──
            _buildHeader(store),

            const SizedBox(height: 16),

            // ── Store name + description ──
            Text(
              store.name,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              store.description,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 14,
                color: Color(0xFF9F9F9F),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),

            // ── Rating | Category | Distance row ──
            _buildInfoRow(store),

            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),

            // ── Products list ──
            ...store.products.map((p) => _buildProductCard(p, store)),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Store store) {
    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Bow-shaped lime green background ──
          ClipPath(
            clipper: _BowClipper(),
            child: Container(
              width: double.infinity,
              height: 220,
              color: const Color(0xFFCDEB45),
            ),
          ),

          // ── Back button (top left) ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back,
                    color: Color(0xFF003E3B), size: 20),
              ),
            ),
          ),

          // ── Heart button (top right) ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: _toggleFavourite,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: const Color(0xFF003E3B),
                  size: 20,
                ),
              ),
            ),
          ),

          // ── Store logo (centered, overlapping wave bottom) ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF003E3B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    store.logoPath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(Store store) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          // Rating
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Rating',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 12,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  store.rating.toString(),
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                _buildStars(store.rating),
              ],
            ),
          ),
          // Category
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Category',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 12,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _getCategoryImage(store.category),
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 36,
                      height: 36,
                      color: const Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCategoryName(store.category),
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 11,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Distance
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Distance',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 12,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  store.distanceKm.toStringAsFixed(0),
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kilometres',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 11,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, Store store) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              product.imagePath,
              width: 94,
              height: 112,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 94,
                height: 112,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 12,
                    color: Color(0xFF9F9F9F),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '${product.price} BD',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003E3B),
                  ),
                ),
                const SizedBox(height: 10),
                // Chat + Order now buttons
                Row(
                  children: [
                    // Chat button
                    GestureDetector(
                      onTap: () {
                        // Find a chat thread for this store, or use the first one
                        final thread = tempChatThreads.firstWhere(
                          (t) => t.storeId == store.id,
                          orElse: () => tempChatThreads.first,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InnerChatPage(chatThread: thread),
                          ),
                        );
                      },
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003E3B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline,
                                color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Chat',
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Order now button
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order placed!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCDEB45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt,
                                color: Color(0xFF003E3B), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Order now',
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF003E3B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          size: 13,
          color: Colors.amber,
        );
      }),
    );
  }
}

// ── Bow clipper (same as home_page.dart) ────────────────────────────────────
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
