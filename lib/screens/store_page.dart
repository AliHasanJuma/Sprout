import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Added for User ID
import '../data/temp_data.dart';
import '../models/cart_model.dart';
import '../providers/cart_provider.dart';
import '../pages/cart_page.dart';
import 'inner_chat_page.dart';

class StorePage extends StatefulWidget {
  final Store store;

  const StorePage({super.key, required this.store});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> with TickerProviderStateMixin {
  int _expandedIndex = -1; // -1 means none expanded
  final CartProvider _cart = CartProvider();

  @override
  void initState() {
    super.initState();
    _cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

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

  String _getCategoryName(String category) {
    return category.replaceAll('\n', ' ');
  }

  void _showOrderSheet(Product product) {
    int quantity = 1;
    String? selectedSize = product.sizes?.isNotEmpty == true ? product.sizes!.first : null;
    final selectedAddons = <String>{};
    final instructionsController = TextEditingController();

    double calcTotal() {
      double base = product.price * quantity;
      if (product.addons != null) {
        for (final addon in product.addons!) {
          if (selectedAddons.contains(addon['name'])) {
            base += (addon['price'] as num).toDouble() * quantity;
          }
        }
      }
      return base;
    }

    double calcAddonsTotal() {
      double total = 0;
      if (product.addons != null) {
        for (final addon in product.addons!) {
          if (selectedAddons.contains(addon['name'])) {
            total += (addon['price'] as num).toDouble();
          }
        }
      }
      return total;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final total = calcTotal();
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDEDEDE),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        24, 8, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product image + name + price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                product.imagePath,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9D9D9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontFamily: 'SF Pro Display',
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    style: const TextStyle(
                                      fontFamily: 'SF Pro Display',
                                      fontSize: 13,
                                      color: Color(0xFF9F9F9F),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${product.price} BD',
                                    style: const TextStyle(
                                      fontFamily: 'SF Pro Display',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF003E3B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Quantity selector
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _sheetCircleButton(
                              icon: Icons.remove,
                              onTap: quantity > 1
                                  ? () => setSheetState(() => quantity--)
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                '$quantity',
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            _sheetCircleButton(
                              icon: Icons.add,
                              onTap: () => setSheetState(() => quantity++),
                            ),
                          ],
                        ),

                        // Size selector
                        if (product.sizes != null && product.sizes!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Size',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            children: product.sizes!.map((size) {
                              final isSelected = selectedSize == size;
                              return GestureDetector(
                                onTap: () => setSheetState(() => selectedSize = size),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF003E3B)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF003E3B)
                                          : const Color(0xFFDEDEDE),
                                    ),
                                  ),
                                  child: Text(
                                    size,
                                    style: TextStyle(
                                      fontFamily: 'SF Pro Display',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        // Add-ons
                        if (product.addons != null && product.addons!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Add-ons',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...product.addons!.map((addon) {
                            final name = addon['name'] as String;
                            final price = (addon['price'] as num).toDouble();
                            final isChecked = selectedAddons.contains(name);
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                name,
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                '+${price.toStringAsFixed(1)} BD',
                                style: const TextStyle(
                                  fontFamily: 'SF Pro Display',
                                  fontSize: 12,
                                  color: Color(0xFF9F9F9F),
                                ),
                              ),
                              value: isChecked,
                              activeColor: const Color(0xFF003E3B),
                              onChanged: (val) {
                                setSheetState(() {
                                  if (val == true) {
                                    selectedAddons.add(name);
                                  } else {
                                    selectedAddons.remove(name);
                                  }
                                });
                              },
                            );
                          }),
                        ],

                        // Special instructions
                        const SizedBox(height: 24),
                        const Text(
                          'Special Instructions',
                          style: TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFDEDEDE)),
                          ),
                          child: TextField(
                            controller: instructionsController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Any special instructions?',
                              hintStyle: TextStyle(
                                fontFamily: 'SF Pro Display',
                                color: Color(0xFFC3C3C3),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(12),
                            ),
                            style: const TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 14,
                            ),
                          ),
                        ),

                        // Total
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '${total.toStringAsFixed(1)} BD',
                              style: const TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003E3B),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Send Order button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _sendOrderToChat(
                                product,
                                quantity,
                                selectedSize,
                                selectedAddons.toList(),
                                instructionsController.text.trim(),
                                total,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Send Order',
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Add to Cart button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              _cart.addItem(CartItem(
                                productId: '${product.id}_${DateTime.now().millisecondsSinceEpoch}',
                                productName: product.name,
                                storeId: widget.store.id,
                                storeName: widget.store.name,
                                unitPrice: product.price,
                                quantity: quantity,
                                selectedSize: selectedSize,
                                selectedAddons: selectedAddons.toList(),
                                addonsTotal: calcAddonsTotal(),
                                specialInstructions:
                                    instructionsController.text.trim().isEmpty
                                        ? null
                                        : instructionsController.text.trim(),
                                productImageUrl: product.imagePath,
                              ));
                              Navigator.pop(ctx);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontFamily: 'SF Pro Display',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sheetCircleButton({required IconData icon, VoidCallback? onTap}) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled ? const Color(0xFF003E3B) : const Color(0xFFEEEEEE),
        ),
        child: Icon(icon, color: enabled ? Colors.white : const Color(0xFF9F9F9F), size: 18),
      ),
    );
  }

  void _sendOrderToChat(
    Product product,
    int quantity,
    String? size,
    List<String> addons,
    String instructions,
    double total,
  ) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return; // Must be logged in

    final buffer = StringBuffer();
    buffer.writeln('🛒 New Order:');
    buffer.writeln('Product: ${product.name}');
    if (size != null) buffer.writeln('Size: $size');
    buffer.writeln('Quantity: $quantity');
    if (addons.isNotEmpty) buffer.writeln('Add-ons: ${addons.join(', ')}');
    if (instructions.isNotEmpty) buffer.writeln('Instructions: $instructions');
    buffer.writeln('Total: ${total.toStringAsFixed(1)} BD');

    // ── CREATE THE SMART CHAT ID ──
    final String chatId = '${uid}_${widget.store.id}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InnerChatPage(
          chatId: chatId,
          storeId: widget.store.id,
          storeName: widget.store.name,
          storeImage: widget.store.logoPath,
          initialMessage: buffer.toString().trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final hasCartItems = _cart.totalItemCount > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: hasCartItems ? 80 : 32),
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
                _buildInfoRow(store),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 16),

                StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('shelves')
      .where('storeId', isEqualTo: store.id)
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF003E3B)));
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No products available yet.',
            style: TextStyle(color: Color(0xFF9F9F9F), fontFamily: 'SF Pro Display'),
          ),
        ),
      );
    }

    final productDocs = snapshot.data!.docs;

    return Column(
      children: List.generate(productDocs.length, (index) {
        final data = productDocs[index].data() as Map<String, dynamic>;
        
        // ── 1. EXTRACT PATHS FROM PHOTOPATHS ARRAY ──
        String resolvedImagePath = 'https://via.placeholder.com/150';
        if (data['photoPaths'] != null && data['photoPaths'] is List && (data['photoPaths'] as List).isNotEmpty) {
          resolvedImagePath = data['photoPaths'][0].toString();
        } else if (data['image'] != null) {
          resolvedImagePath = data['image'].toString();
        }

        // ── 2. ISOLATE AND RE-TYPE ADDONS ENTIRELY BEFORE MODEL PARSING ──
        final rawAddons = data['addOns'] ?? data['addons'];
        List<Map<String, dynamic>>? parsedAddons;
        
        if (rawAddons != null && rawAddons is List) {
          parsedAddons = List<Map<String, dynamic>>.from(
            rawAddons.map((item) {
              if (item is Map) {
                return Map<String, dynamic>.from(item);
              }
              return <String, dynamic>{};
            }),
          );
        }

        return _buildExpandableProductCard(
          Product(
            id: productDocs[index].id,
            name: data['name'] ?? 'Unknown Product',
            description: data['description'] ?? '',
            price: (data['price'] ?? 0.0).toDouble(),
            imagePath: resolvedImagePath,
            allergens: data['allergens'],
            weight: data['weight'],
            addons: parsedAddons, // Directly passes the strictly compiled typed list
            
            ingredients: data['ingredients'] != null && data['ingredients'] is List
                ? (data['ingredients'] as List).map((item) => item.toString()).toList()
                : null,
                
            sizes: data['sizes'] != null && data['sizes'] is List
                ? (data['sizes'] as List).map((item) {
                    if (item is Map) {
                      return item['size']?.toString() ?? '';
                    }
                    return item.toString();
                  }).where((element) => element.isNotEmpty).toList()
                : null,
          ),
          store,
          index,
        );
      }),
    );
  },
),
                
                const SizedBox(height: 32),
              ],
            ),
          ),

          if (hasCartItems)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildFloatingCartBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingCartBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFCDEB45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_cart.totalItemCount} ${_cart.totalItemCount == 1 ? 'item' : 'items'}',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'View Cart',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              '${_cart.grandTotal.toStringAsFixed(1)} BD',
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFCDEB45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Store store) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: _BowClipper(),
            child: Container(
              width: double.infinity,
              height: 220,
              color: const Color(0xFFCDEB45),
            ),
          ),
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
          
          // ── NEW: DYNAMIC HEART BUTTON ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
              builder: (context, snapshot) {
                bool isFav = false;
                
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final List<dynamic> favs = data['favouriteStoreIds'] ?? [];
                  isFav = favs.contains(store.id);
                }

                return GestureDetector(
                  onTap: () async {
                    if (uid == null) return;
                    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
                    
                    // ── Change .update() to a safe .set() with merge: true ──
if (isFav) {
  await userRef.set({
    'favouriteStoreIds': FieldValue.arrayRemove([store.id])
  }, SetOptions(merge: true)); // Creates the document if missing, updates if it exists!
} else {
  await userRef.set({
    'favouriteStoreIds': FieldValue.arrayUnion([store.id])
  }, SetOptions(merge: true));
}
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: const Color(0xFF003E3B),
                      size: 20,
                    ),
                  ),
                );
              }
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
                  child: Image.network(
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
          Expanded(
            child: Column(
              children: [
                const Text('Rating',
                    style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 12,
                        color: Color(0xFF9F9F9F))),
                const SizedBox(height: 4),
                Text(store.rating.toString(),
                    style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 4),
                _buildStars(store.rating),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text('Category',
                    style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 12,
                        color: Color(0xFF9F9F9F))),
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
                Text(_getCategoryName(store.category),
                    style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 11,
                        color: Colors.black),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text('Distance',
                    style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 12,
                        color: Color(0xFF9F9F9F))),
                const SizedBox(height: 4),
                Text(store.distanceKm.toStringAsFixed(0),
                    style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 4),
                const Text('Kilometres',
                    style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 11,
                        color: Color(0xFF9F9F9F))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableProductCard(Product product, Store store, int index) {
    final isExpanded = _expandedIndex == index;

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
            // Main card content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              product.description,
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
                        '${product.price} BD',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003E3B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          // Chat button with PNG icon
                          GestureDetector(
                          onTap: () {
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid == null) return;
                            
                            // ── CREATE THE SMART CHAT ID ──
                            final String chatId = '${uid}_${store.id}';

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => InnerChatPage(
                                  chatId: chatId,
                                  storeId: store.id,
                                  storeName: store.name,
                                  storeImage: store.logoPath,
                                ),
                              ),
                            );
                          },
                          child: Container(
                              height: 30,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF003E3B),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/UI icons package/PNG/White/Communication/Chat_Circle.png',
                                    width: 14,
                                    height: 14,
                                    color: Colors.white,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
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
                          // Order now button with outlined bolt icon
                          GestureDetector(
                            onTap: () => _showOrderSheet(product),
                            child: Container(
                              height: 30,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFCDEB45),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.flash_on_outlined,
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

            // Expanded section
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedSection(product),
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

  Widget _buildExpandedSection(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),

        // Ingredients
        if (product.ingredients != null && product.ingredients!.isNotEmpty) ...[
          Row(
            children: [
              Image.asset(
                'assets/icons/Ingredient_list.png',
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.restaurant_menu,
                    size: 20,
                    color: Color(0xFF003E3B)),
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
            children: product.ingredients!
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

        // Allergens
        if (product.allergens != null) ...[
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 18, color: Color(0xFFE6A800)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  product.allergens!,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 12,
                    color: Color(0xFFE6A800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Weight
        if (product.weight != null) ...[
          Row(
            children: [
              const Icon(Icons.scale_outlined,
                  size: 16, color: Color(0xFF9F9F9F)),
              const SizedBox(width: 6),
              Text(
                'Weight: ${product.weight}',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 12,
                  color: Color(0xFF9F9F9F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Sizes
        if (product.sizes != null && product.sizes!.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.straighten_outlined,
                  size: 16, color: Color(0xFF9F9F9F)),
              const SizedBox(width: 6),
              Text(
                'Available sizes: ${product.sizes!.join(', ')}',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 12,
                  color: Color(0xFF9F9F9F),
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