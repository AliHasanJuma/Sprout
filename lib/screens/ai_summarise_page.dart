// TODO: Replace with Firebase
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/temp_data.dart';

class AiSummarisePage extends StatefulWidget {
  final Store store;

  const AiSummarisePage({super.key, required this.store});

  @override
  State<AiSummarisePage> createState() => _AiSummarisePageState();
}

class _AiSummarisePageState extends State<AiSummarisePage> {
  // Track quantities for first 2 products
  late List<int> _quantities;
  late List<bool> _visible;

  @override
  void initState() {
    super.initState();
    final count = widget.store.products.length.clamp(0, 2);
    _quantities = List.filled(count, 1);
    _visible = List.filled(count, true);
  }

  double get _totalPrice {
    double total = 0;
    for (int i = 0; i < _quantities.length; i++) {
      if (_visible[i]) {
        total += widget.store.products[i].price * _quantities[i];
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.store.products.take(2).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ── Sparkle icon ──
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

              // ── Description text ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'AI that instantly summarize your conversation and finalize your order with a single click',
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: Color(0xFF9F9F9F),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 32),

              // ── Main card ──
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Product rows
                    for (int i = 0; i < products.length; i++) ...[
                      if (_visible[i]) ...[
                        if (i > 0 && _visible.take(i).any((v) => v))
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child:
                                Divider(height: 1, color: Color(0xFFDEDEDE)),
                          ),
                        _buildProductRow(products[i], i),
                      ],
                    ],

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: Color(0xFFDEDEDE)),
                    ),

                    // ── Delivery details ──
                    _buildDeliveryRow(),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: Color(0xFFDEDEDE)),
                    ),

                    // ── Total price ──
                    _buildTotalRow(),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Send button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order sent successfully!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
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
                          'Send',
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

              // ── Go back button ──
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
        ),
      ),
    );
  }

  Widget _buildProductRow(Product product, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product info (left)
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
                '${product.description}\nAlso here ere the seller place the description of the product',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 12,
                  color: Color(0xFF9F9F9F),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${product.price} BD',
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

        // Image + quantity controls (right)
        Column(
          children: [
            // Product image placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                product.imagePath,
                width: 98,
                height: 116,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 98,
                  height: 116,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Quantity pill
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF003E3B),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Trash / minus
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_quantities[index] <= 1) {
                          _visible[index] = false;
                        } else {
                          _quantities[index]--;
                        }
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.delete_outline,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  Text(
                    '${_quantities[index]}',
                    style: const TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Plus
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _quantities[index]++;
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child:
                          Icon(Icons.add, color: Colors.white, size: 16),
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

  Widget _buildDeliveryRow() {
    return Row(
      children: [
        // Delivery icon
        SvgPicture.asset(
          'assets/Essentials/Added/delivery.svg',
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(
            Color(0xFF003E3B),
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 12),
        // Delivery text
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery details',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Here the seller place the description of the Delivery of the product',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 12,
                  color: Color(0xFF9F9F9F),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Edit button
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFF003E3B),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.edit, color: Colors.white, size: 18),
        ),
      ],
    );
  }

  Widget _buildTotalRow() {
    return Row(
      children: [
        const Icon(Icons.local_offer_outlined,
            color: Color(0xFF003E3B), size: 28),
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
              '${_totalPrice.toStringAsFixed(1)} BD',
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
