import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';

class OrderStatusCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final String chatId;
  final String storeId;
  final String storeName;
  final String storeImage;
  final VoidCallback onOrderCancelled;

  const OrderStatusCard({
    super.key,
    required this.order,
    required this.chatId,
    required this.storeId,
    required this.storeName,
    required this.storeImage,
    required this.onOrderCancelled,
  });

  @override
  State<OrderStatusCard> createState() => _OrderStatusCardState();
}

class _OrderStatusCardState extends State<OrderStatusCard> {
  bool _isCancelling = false;
  
  // Cache for product images
  final Map<String, String> _productImages = {};

  String getStatusDisplay() {
    final status = widget.order['status'] ?? 'requested';
    switch (status) {
      case 'requested':
        return 'Pending orders';
      case 'accepted':
        return 'Accepted';
      case 'declined':
        return 'Declined';
      case 'cancelled_by_buyer':
        return 'Cancelled';
      case 'completed_by_seller':
        return 'Completed';
      case 'received_by_buyer':
        return 'Received';
      default:
        return status;
    }
  }

  Color getStatusColor() {
    final status = widget.order['status'] ?? 'requested';
    switch (status) {
      case 'requested':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'cancelled_by_buyer':
        return Colors.red;
      case 'completed_by_seller':
        return Colors.green;
      case 'received_by_buyer':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  Future<String> _fetchProductImage(String productName) async {
    // Return cached image if available
    if (_productImages.containsKey(productName)) {
      return _productImages[productName]!;
    }
    
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('storeId', isEqualTo: widget.storeId)
          .where('name', isEqualTo: productName)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final imageUrl = querySnapshot.docs.first.data()['imageUrl'] as String? ?? '';
        _productImages[productName] = imageUrl;
        return imageUrl;
      }
    } catch (e) {
      print('Error fetching product image: $e');
    }
    return '';
  }

  String _formatCancellationMessage() {
    final items = widget.order['items'] as List<dynamic>? ?? [];
    final totalPrice = (widget.order['totalPrice'] as num?)?.toDouble() ?? 0;
    
    String message = '❌ Order has been cancelled by buyer.\n\n';
    message += 'Details:\n';
    message += 'Items: ${items.length}\n';
    
    for (var item in items) {
      final name = item['name'] ?? 'Unknown';
      final quantity = item['quantity'] ?? 1;
      final pricePerUnit = (item['price_per_unit'] as num?)?.toDouble() ?? 0;
      message += '• $name (Qty: $quantity × ${pricePerUnit.toStringAsFixed(2)} BD)\n';
    }
    
    message += '\nTotal: ${totalPrice.toStringAsFixed(2)} BD';
    
    return message;
  }

  Future<void> _cancelOrder() async {
    setState(() => _isCancelling = true);
    
    try {
      await FirebaseFirestore.instance
          .collection('orderIntents')
          .doc(widget.order['id'])
          .update({
        'status': 'cancelled_by_buyer',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add detailed cancellation message to chat
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': _formatCancellationMessage(),
        'senderId': 'system',
        'senderName': 'System',
        'timestamp': FieldValue.serverTimestamp(),
      });

      widget.onOrderCancelled();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order cancelled')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling order: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.order['items'] as List<dynamic>? ?? [];
    final totalPrice = (widget.order['totalPrice'] as num?)?.toDouble() ?? 0;
    final deliveryMethod = widget.order['deliveryMethod'] ?? 'Not specified';
    final status = widget.order['status'] ?? 'requested';
    final isCancelled = status == 'cancelled_by_buyer';

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: getStatusColor().withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  status == 'requested' ? Icons.pending : Icons.cancel,
                  color: getStatusColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  getStatusDisplay(),
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: _fetchProductImage(items[i]['name'] ?? 'Unknown'),
                    builder: (context, snapshot) {
                      final imageUrl = snapshot.data ?? '';
                      return _buildOrderItem(items[i], imageUrl);
                    },
                  ),
                ],
                const Divider(height: 24, color: Color(0xFFEEEEEE)),
                _buildDeliveryRow(deliveryMethod),
                const Divider(height: 24, color: Color(0xFFEEEEEE)),
                _buildTotalRow(totalPrice),
                if (!isCancelled) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Back to Chat',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isCancelling ? null : _cancelOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isCancelling
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Cancel order',
                                  style: TextStyle(
                                    fontFamily: 'SF Pro Display',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item, String imageUrl) {
    final name = item['name'] ?? 'Unknown';
    final quantity = item['quantity'] ?? 1;
    final pricePerUnit = (item['price_per_unit'] as num?)?.toDouble() ?? 0;
    final itemTotal = quantity * pricePerUnit;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: imageUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.image, color: Color(0xFF9F9F9F), size: 30),
                    ),
                  ),
                )
              : const Center(
                  child: Icon(Icons.image, color: Color(0xFF9F9F9F), size: 30),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Qty: $quantity × ${pricePerUnit.toStringAsFixed(2)} BD',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 12,
                  color: Color(0xFF9F9F9F),
                ),
              ),
            ],
          ),
        ),
        Text(
          '${itemTotal.toStringAsFixed(2)} BD',
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryRow(String deliveryMethod) {
    return Row(
      children: [
        const Icon(Icons.local_shipping, size: 20, color: Color(0xFF9F9F9F)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Delivery: $deliveryMethod',
            style: const TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 13,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalRow(double totalPrice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total Price',
          style: TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          '${totalPrice.toStringAsFixed(2)} BD',
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}