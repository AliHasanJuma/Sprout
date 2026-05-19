// TODO(i18n): EN-only. Arabic translations needed for: "Pick up order",
// "enter order pick up code", "Incorrect code. Please try again.",
// "Handoff from".
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/order_card_data.dart';
import '../providers/order_repository.dart';
import '../shared/widgets/order_card.dart';
import '../shared/widgets/otp_input.dart';
import 'rating_page.dart';

/// Image 5 — buyer types the 4-digit pickup code the seller reads aloud.
/// Correct code → mark order completed and continue to the rating flow.
/// Wrong code → inline red error, clear inputs after a short delay.
class BuyerPickupCodePage extends StatefulWidget {
  final OrderCardData order;

  const BuyerPickupCodePage({super.key, required this.order});

  @override
  State<BuyerPickupCodePage> createState() => _BuyerPickupCodePageState();
}

class _BuyerPickupCodePageState extends State<BuyerPickupCodePage> {
  final GlobalKey<OtpInputState> _otpKey = GlobalKey<OtpInputState>();
  final OrderRepository _repo = OrderRepository();

  String? _error;
  bool _busy = false;

  String _initials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase();
  }

  Future<void> _onCompleted(String code) async {
    if (_busy) return;
    setState(() => _busy = true);

    // TODO(backend): validate against orders/{orderId}.pickupCode via a
    // Cloud Function so the buyer can't read the seller's code from the
    // client. For the mock layer we compare in-memory.
    final ok = _repo.checkPickupCode(widget.order.orderId, code);
    if (ok) {
      _repo.updateStatus(widget.order.orderId, OrderStatus.completed);
      if (!mounted) return;
      final fresh = _repo.getById(widget.order.orderId) ?? widget.order;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RatingPage(order: fresh)),
      );
    } else {
      setState(() => _error = 'Incorrect code. Please try again.');
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      _otpKey.currentState?.clear();
      setState(() {
        _error = null;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              _TopBar(
                title: 'Pick up order',
                onBack: () => Navigator.pop(context),
              ),
              const SizedBox(height: 40),
              const Text(
                'enter order pick up code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              // Reference image shows tightly grouped 4 boxes (~12 px gap),
              // not spread across the full screen. Wrap in a narrow,
              // centered SizedBox so spaceBetween only has ~36 px of slack
              // to distribute (3 gaps of ~12 each).
              Center(
                child: SizedBox(
                  width: 260,
                  child: OtpInput(
                    key: _otpKey,
                    length: 4,
                    boxWidth: 56,
                    boxHeight: 60,
                    onCompleted: _onCompleted,
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              _HandoffRow(
                label: 'Handoff from',
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
