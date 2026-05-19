import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for Firebase UID
import '../models/cart_model.dart';
import '../providers/cart_provider.dart';
import '../data/temp_data.dart';
import '../screens/inner_chat_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
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

  String _formatCartMessage(List<CartItem> items) {
    final buffer = StringBuffer();
    buffer.writeln('🛒 Cart Order:');
    for (final item in items) {
      buffer.write('${item.quantity}× ${item.productName}');
      if (item.selectedSize != null) buffer.write(' (${item.selectedSize})');
      buffer.writeln(' — ${item.totalPrice.toStringAsFixed(1)} BD');
      if (item.selectedAddons.isNotEmpty) {
        buffer.writeln('   Add-ons: ${item.selectedAddons.join(', ')}');
      }
      if (item.specialInstructions != null) {
        buffer.writeln('   Instructions: ${item.specialInstructions}');
      }
    }
    final total = items.fold(0.0, (sum, i) => sum + i.totalPrice);
    buffer.writeln('─────────────');
    buffer.writeln('Total: ${total.toStringAsFixed(1)} BD');
    return buffer.toString().trim();
  }

  void _sendCartToChat() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return; // Failsafe

    final byStore = _cart.itemsByStore;
    if (byStore.isEmpty) return;

    // Send to first store's chat, then navigate there
    final firstStoreId = byStore.keys.first;
    final firstItems = byStore[firstStoreId]!;
    final message = _formatCartMessage(firstItems);
    
    // We grab the store name from the first item in the cart
    final storeName = firstItems.first.storeName;

    // ── CREATE THE SMART CHAT ID ──
    final String chatId = '${uid}_$firstStoreId';

    _cart.clearCart();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => InnerChatPage(
          chatId: chatId,
          storeId: firstStoreId,
          storeName: storeName,
          storeImage: '', // Blank defaults to the initials avatar 
          initialMessage: message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _cart.items;
    final isEmpty = items.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF003E3B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: isEmpty ? _buildEmptyState() : _buildCartContent(items),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Color(0xFFDEDEDE)),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9F9F9F),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add items from a store to get started',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 14,
              color: Color(0xFFC3C3C3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(List<CartItem> items) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildCartItemCard(items[index]);
            },
          ),
        ),
        _buildOrderSummary(items),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Dismissible(
      key: Key(item.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
      ),
      onDismissed: (_) => _cart.removeItem(item.productId),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
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
            if (item.productImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                // Using NetworkImage to support Firebase links instead of AssetImage
                child: Image.network(
                  item.productImageUrl!,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            if (item.productImageUrl != null) const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.storeName,
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 12,
                      color: Color(0xFF9F9F9F),
                    ),
                  ),
                  if (item.selectedSize != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Size: ${item.selectedSize}',
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 12,
                        color: Color(0xFF9F9F9F),
                      ),
                    ),
                  ],
                  if (item.selectedAddons.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Add-ons: ${item.selectedAddons.join(', ')}',
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 12,
                        color: Color(0xFF9F9F9F),
                      ),
                    ),
                  ],
                  if (item.specialInstructions != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.specialInstructions!,
                      style: const TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFFC3C3C3),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Quantity + price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.totalPrice.toStringAsFixed(1)} BD',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003E3B),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF003E3B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (item.quantity <= 1) {
                            _cart.removeItem(item.productId);
                          } else {
                            _cart.updateQuantity(
                                item.productId, item.quantity - 1);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(
                            item.quantity <= 1
                                ? Icons.delete_outline
                                : Icons.remove,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _cart.updateQuantity(
                            item.productId, item.quantity + 1),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(List<CartItem> items) {
    final subtotal = _cart.grandTotal;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
                Text(
                  '${subtotal.toStringAsFixed(1)} BD',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
                Text(
                  'TBD',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: Color(0xFF9F9F9F),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${subtotal.toStringAsFixed(1)} BD',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003E3B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _sendCartToChat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Send Order to Chat',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}