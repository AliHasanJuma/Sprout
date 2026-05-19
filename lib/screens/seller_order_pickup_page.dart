// TODO(i18n): EN-only. Arabic translations needed for: "Order Pickup",
// "Ask the buyer to enter this code to confirm delivery.",
// "Pick up Code:", "Handoff to".
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/order_card_data.dart';
import '../providers/order_repository.dart';
import '../shared/widgets/order_card.dart';

/// Image 10 — the screen the seller lands on after pressing "Ready for
/// Handoff". Shows the 4-digit pickup code the seller reads aloud to the
/// buyer, plus the order card (read-only) for context.
///
/// The seller can navigate back; the order stays in [OrderStatus.ready]
/// until the buyer completes the pickup code entry. Once the buyer's
/// device flips the order to [OrderStatus.completed], this page auto-pops
/// so the seller is dropped back into the chat — no manual back tap.
class SellerOrderPickupPage extends StatefulWidget {
  final OrderCardData order;

  const SellerOrderPickupPage({super.key, required this.order});

  @override
  State<SellerOrderPickupPage> createState() => _SellerOrderPickupPageState();
}

class _SellerOrderPickupPageState extends State<SellerOrderPickupPage> {
  final OrderRepository _repo = OrderRepository();

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  /// When the buyer enters the correct pickup code on their device, the
  /// OrderRepository snapshot listener flips this order to completed. Pop
  /// back to the chat so the seller sees the completed card immediately.
  void _onRepoChanged() {
    if (!mounted) return;
    final fresh = _repo.getById(widget.order.orderId);
    if (fresh == null) return;
    if (fresh.status == OrderStatus.completed) {
      Navigator.of(context).pop();
    }
  }

  String _initials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Use the freshest copy of the order from the repo cache so any
    // status / detail update propagates without restarting the page.
    final order = _repo.getById(widget.order.orderId) ?? widget.order;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _TopBar(title: 'Order Pickup', onBack: () => Navigator.pop(context)),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Ask the buyer to enter this code\nto confirm delivery.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _PickupCodeBox(code: order.pickupCode),
              const SizedBox(height: 32),
              _HandoffRow(
                label: 'Handoff to',
                storeName: order.storeName,
                avatarUrl: order.storeAvatarUrl,
                initials: _initials(order.storeName),
              ),
              const SizedBox(height: 24),
              OrderCard(order: order, showStatusBadge: false),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
            onPressed: onBack,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _PickupCodeBox extends StatelessWidget {
  final String code;

  const _PickupCodeBox({required this.code});

  @override
  Widget build(BuildContext context) {
    // Reference image shows a compact pill-style box, ~70% of screen
    // width, not full-bleed. ConstrainedBox + Center matches the mockup.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 17,
                color: AppColors.secondary,
              ),
              children: [
                const TextSpan(text: 'Pick up Code: '),
                TextSpan(
                  text: code,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HandoffRow extends StatelessWidget {
  final String label;
  final String storeName;
  final String? avatarUrl;
  final String initials;

  const _HandoffRow({
    required this.label,
    required this.storeName,
    required this.avatarUrl,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 15,
            color: Color(0xFF9F9F9F),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary,
          backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
              ? NetworkImage(avatarUrl!)
              : null,
          child: (avatarUrl == null || avatarUrl!.isEmpty)
              ? Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Text(
          storeName,
          style: const TextStyle(
            fontFamily: 'SF Pro Display',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
