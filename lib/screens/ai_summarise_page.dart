import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/serivces/groq_order_service.dart';

class AiSummarisePage extends StatefulWidget {
  final String chatId;
  final String storeId;
  final String storeName;
  final String storeImage;

  const AiSummarisePage({
    super.key,
    required this.chatId,
    required this.storeId,
    required this.storeName,
    required this.storeImage,
  });

  @override
  State<AiSummarisePage> createState() => _AiSummarisePageState();
}

class _AiSummarisePageState extends State<AiSummarisePage> {
  bool _isLoading = true;
  String? _error;
  
  // AI extracted data
  List<Map<String, dynamic>> _extractedItems = [];
  double _totalPrice = 0;
  String _deliveryMethod = '';
  String _deliveryArea = '';
  String _notes = '';
  bool _hasOrder = false;
  
  // Manual override controls
  final Map<int, int> _quantities = {};
  final Map<int, bool> _visible = {};
  
  // Store products from Firestore
  List<QueryDocumentSnapshot> _storeProducts = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch store products from Firestore
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('storeId', isEqualTo: widget.storeId)
          .get();
      
      _storeProducts = productsSnapshot.docs;
      
      // Convert products to format for AI
      final productsForAI = _storeProducts.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Safe way to get values
        final nameValue = data['name'];
        final priceValue = data['price'];
        
        final String name;
        if (nameValue == null) {
          name = 'Unknown';
        } else {
          name = nameValue.toString();
        }
        
        final double price;
        if (priceValue == null) {
          price = 0.0;
        } else if (priceValue is int) {
          price = priceValue.toDouble();
        } else if (priceValue is double) {
          price = priceValue;
        } else {
          price = 0.0;
        }
        
        return {
          'name': name,
          'price': price,
        };
      }).toList();
      
      // After fetching products, add this debug
print('=== STORE PRODUCTS ===');
for (var product in productsForAI) {
  print('Product: ${product['name']} - ${product['price']} BHD');
}
print('=====================');

      // Call groq API to extract order from chat
      final aiResult = await GroqOrderService.extractOrderFromChat(
        chatId: widget.chatId,
        storeName: widget.storeName,
        storeProducts: productsForAI,
      );

      print('=== AI RESULT PARSED ===');
      print(aiResult);
      print('has_order: ${aiResult['has_order']}');
      print('=======================');
     
      if (aiResult['has_order'] == true) {
        _hasOrder = true;
        
        // Process extracted items
        final items = aiResult['items'] as List<dynamic>? ?? [];
        for (var i = 0; i < items.length; i++) {
          final item = items[i];
          _extractedItems.add({
            'name': item['name'] as String? ?? 'Unknown',
            'quantity': item['quantity'] as int? ?? 1,
            'price_per_unit': (item['price_per_unit'] as num? ?? 0).toDouble(),
          });
          _quantities[i] = item['quantity'] as int? ?? 1;
          _visible[i] = true;
        }
        
        _totalPrice = (aiResult['total_price'] as num? ?? 0).toDouble();
        _deliveryMethod = aiResult['delivery_method'] as String? ?? 'Not specified';
        _deliveryArea = aiResult['delivery_area'] as String? ?? 'Not specified';
        _notes = aiResult['notes'] as String? ?? '';
      } else {
        _hasOrder = false;
        _error = 'No order detected in the conversation. Make sure you and the seller have agreed on items and prices.';
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to analyze chat: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createOrderIntent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('User not logged in');

      // Prepare items list for storage
      final itemsList = [];
      for (int i = 0; i < _extractedItems.length; i++) {
        if (_visible[i] == true) {
          itemsList.add({
            'name': _extractedItems[i]['name'],
            'quantity': _quantities[i] ?? 1,
            'price_per_unit': _extractedItems[i]['price_per_unit'],
          });
        }
      }

      // Create order intent in Firestore
      await FirebaseFirestore.instance.collection('orderIntents').add({
        'chatId': widget.chatId,
        'buyerId': currentUser.uid,
        'storeId': widget.storeId,
        'storeName': widget.storeName,
        'items': itemsList,
        'totalPrice': _totalPrice,
        'deliveryMethod': _deliveryMethod,
        'deliveryArea': _deliveryArea,
        'notes': _notes,
        'status': 'requested',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add a system message to the chat
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': '🛍️ **Order Request Created!**\n\nItems: ${itemsList.length}\nTotal: $_totalPrice BHD\nDelivery: $_deliveryMethod\n\nPlease check your order requests tab.',
        'senderId': 'system',
        'senderName': 'System',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order request sent to seller!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating order: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF003E3B)),
                    SizedBox(height: 16),
                    Text(
                      'AI is analyzing your conversation...',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 14,
                        color: Color(0xFF9F9F9F),
                      ),
                    ),
                  ],
                ),
              )
            : _error != null
                ? _buildErrorView()
                : _buildSummaryView(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/Essentials/Added/star.svg',
              width: 60,
              height: 60,
            ),
            const SizedBox(height: 24),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 14,
                color: Color(0xFF9F9F9F),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCDEB45),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003E3B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),

          SvgPicture.asset(
            'assets/Essentials/Added/star.svg',
            width: 60,
            height: 60,
            colorFilter: const ColorFilter.mode(
              Color(0xFFCDEB45),
              BlendMode.srcIn,
            ),
          ),

          const SizedBox(height: 16),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'AI has summarized your conversation. Review and confirm the order details below.',
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 14,
                color: Color(0xFF9F9F9F),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 32),

          // Main order card - FIXED: Changed _visible.take to proper list check
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _extractedItems.length; i++) ...[
                  if (_visible[i] == true) ...[
                    if (i > 0 && _hasPreviousVisibleItem(i))
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Divider(height: 1, color: Color(0xFFDEDEDE)),
                      ),
                    _buildItemRow(_extractedItems[i], i),
                  ],
                ],

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: Color(0xFFDEDEDE)),
                ),

                _buildDeliveryRow(),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: Color(0xFFDEDEDE)),
                ),

                _buildTotalRow(),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Send order button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: GestureDetector(
              onTap: _createOrderIntent,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFCDEB45),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, color: Color(0xFF003E3B), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Send Order Request',
                      style: TextStyle(
                        fontFamily: 'SF Pro Display',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003E3B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, color: Colors.black, size: 18),
                SizedBox(width: 6),
                Text(
                  'Go back',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Helper method to check if there's any visible item before the current index
  bool _hasPreviousVisibleItem(int currentIndex) {
    for (int i = 0; i < currentIndex; i++) {
      if (_visible[i] == true) {
        return true;
      }
    }
    return false;
  }

  Widget _buildItemRow(Map<String, dynamic> item, int index) {
    final qty = _quantities[index] ?? 1;
    final isTrash = qty <= 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name'],
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _notes.isNotEmpty ? _notes : 'No additional notes',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 12,
                  color: Color(0xFF9F9F9F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${item['price_per_unit']} BD / each',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003E3B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF003E3B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isTrash) {
                          _visible[index] = false;
                        } else {
                          _quantities[index] = qty - 1;
                          _updateTotalPrice();
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        isTrash ? Icons.delete_outline : Icons.remove,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  Text(
                    '$qty',
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _quantities[index] = qty + 1;
                        _updateTotalPrice();
                      });
                    },
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
    );
  }

  void _updateTotalPrice() {
    _totalPrice = 0;
    for (int i = 0; i < _extractedItems.length; i++) {
      if (_visible[i] == true) {
        _totalPrice += (_extractedItems[i]['price_per_unit'] as double) * (_quantities[i] ?? 1);
      }
    }
    setState(() {});
  }

  Widget _buildDeliveryRow() {
    return Row(
      children: [
        Image.asset(
          'assets/Essentials/Added/delivery.png',
          width: 28,
          height: 28,
          color: const Color(0xFF003E3B),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery details',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Method: $_deliveryMethod\nArea: $_deliveryArea',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 12,
                  color: Color(0xFF9F9F9F),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showEditDeliveryDialog(),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF003E3B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  void _showEditDeliveryDialog() {
    final TextEditingController methodController = TextEditingController(text: _deliveryMethod);
    final TextEditingController areaController = TextEditingController(text: _deliveryArea);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Delivery Details',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Delivery Method'),
              const SizedBox(height: 4),
              TextField(
                controller: methodController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Pickup, Courier',
                ),
              ),
              const SizedBox(height: 16),
              const Text('Delivery Area'),
              const SizedBox(height: 4),
              TextField(
                controller: areaController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Manama, Riffa',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _deliveryMethod = methodController.text;
                      _deliveryArea = areaController.text;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCDEB45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTotalRow() {
    return Row(
      children: [
        const Icon(Icons.local_offer_outlined, color: Color(0xFF003E3B), size: 28),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 4),
            Text(
              '${_totalPrice.toStringAsFixed(2)} BHD',
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 14,
                color: Color(0xFF9F9F9F),
              ),
            ),
          ],
        ),
      ],
    );
  }
}