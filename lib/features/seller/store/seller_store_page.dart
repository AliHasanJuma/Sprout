import 'dart:io';

import 'package:flutter/material.dart';

import '../models/shelf_model.dart';
import '../models/store_model.dart';
import '../services/shelf_service.dart';
import '../settings/store_settings_page.dart';
import '../shelf/create_shelf_page.dart';
import '../shelves_tab.dart';

class SellerStorePage extends StatefulWidget {
  final StoreModel store;
  const SellerStorePage({super.key, required this.store});

  @override
  State<SellerStorePage> createState() => _SellerStorePageState();
}

class _SellerStorePageState extends State<SellerStorePage>
    with TickerProviderStateMixin {
  int _expandedIndex = -1; // -1 means none expanded
  List<ShelfModel> _shelves = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadShelves();
  }

  Future<void> _loadShelves() async {
    final shelves = await ShelfService().getMyShelves();
    if (!mounted) return;
    setState(() {
      _shelves = shelves;
      _loading = false;
    });
  }

  Future<void> _openCreateShelf() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateShelfPage()),
    );
    _loadShelves();
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StoreSettingsPage()),
    );
    if (!mounted) return;
    SellerReloadNotification().dispatch(context);
  }

  Future<void> _editShelf(ShelfModel shelf) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateShelfPage(initial: shelf, isEditing: true),
      ),
    );
    _loadShelves();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            _buildHeader(store),
            const SizedBox(height: 16),
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
              store.bio,
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
            _buildInfoRow(store),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 16),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF003E3B)),
                ),
              )
            else if (_shelves.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No products available yet.',
                    style: TextStyle(
                      color: Color(0xFF9F9F9F),
                      fontFamily: 'SF Pro Display',
                    ),
                  ),
                ),
              )
            else
              Column(
                children: List.generate(_shelves.length, (index) {
                  return _buildExpandableShelfCard(_shelves[index], index);
                }),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(StoreModel store) {
    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: _BowClipper(),
            child: SizedBox(
              width: double.infinity,
              height: 220,
              child: store.bannerPath != null
                  ? Image.file(
                      File(store.bannerPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFFCDEB45),
                      ),
                    )
                  : Container(color: const Color(0xFFCDEB45)),
            ),
          ),

          // ── SELLER: `+` button replaces buyer's back arrow ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: _openCreateShelf,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/UI icons package/PNG/Black/Edit/Add_Plus.png',
                    width: 18,
                    height: 18,
                    color: const Color(0xFF003E3B),
                  ),
                ),
              ),
            ),
          ),

          // ── SELLER: `…` button replaces buyer's favourite heart ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: GestureDetector(
              onTap: _openSettings,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/UI icons package/PNG/Black/Menu/More_Horizontal.png',
                    width: 18,
                    height: 18,
                    color: const Color(0xFF003E3B),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 20,
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
                  child: store.logoPath != null
                      ? Image.file(
                          File(store.logoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(StoreModel store) {
    // TODO: wire Views/Rating/Orders to Firestore.
    const int views = 84;
    const double rating = 3.5;
    const int orders = 5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: const [
                Text(
                  'Views',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 12,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$views',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'This month',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 11,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
              ],
            ),
          ),
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
                const Text(
                  '$rating',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                _buildStars(rating),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: const [
                Text(
                  'Orders',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 12,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$orders',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Active',
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

  Widget _buildExpandableShelfCard(ShelfModel shelf, int index) {
    final isExpanded = _expandedIndex == index;
    final hasPhoto = shelf.photoPaths.isNotEmpty;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = isExpanded ? -1 : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: hasPhoto
                      ? Image.file(
                          File(shelf.photoPaths.first),
                          width: 94,
                          height: 112,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 94,
                            height: 112,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      : Container(
                          width: 94,
                          height: 112,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shelf.name,
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              shelf.description,
                              style: const TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 12,
                                color: Color(0xFF9F9F9F),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFF9F9F9F),
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${shelf.price} BD',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003E3B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // ── SELLER: single `Edit shelf` pill replaces Chat + Order now ──
                      GestureDetector(
                        onTap: () => _editShelf(shelf),
                        child: Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003E3B),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/UI icons package/PNG/Black/Edit/Edit_Pencil_Line_01.png',
                                width: 14,
                                height: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Edit shelf',
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
                    ],
                  ),
                ),
              ],
            ),

            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedSection(shelf),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedSection(ShelfModel shelf) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),

        if (shelf.ingredients.isNotEmpty) ...[
          Row(
            children: [
              Image.asset(
                'assets/icons/Ingredient_list.png',
                width: 20,
                height: 20,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.restaurant_menu,
                  size: 20,
                  color: Color(0xFF003E3B),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: shelf.ingredients
                .map((ing) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ing,
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],

        if (shelf.sizes.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.straighten_outlined,
                  size: 16, color: Color(0xFF9F9F9F)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Available sizes: ${shelf.sizes.map((s) => '${s.size} (${s.price} BD)').join(', ')}',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 12,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        if (shelf.addOns.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.add_circle_outline,
                  size: 16, color: Color(0xFF9F9F9F)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Add-ons: ${shelf.addOns.map((a) => '${a.name} (+${a.price} BD)').join(', ')}',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 12,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
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
      size.width / 2,
      controlY,
      size.width,
      size.height,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_BowClipper oldClipper) => false;
}
