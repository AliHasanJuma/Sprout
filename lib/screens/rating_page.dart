// TODO(i18n): EN-only. Arabic translations needed for: "How was your order
// from <storeName>?", star labels ("Not good", "Could be better", "It was
// alright", "Pretty good", "Excellent!"), "Tell us a little more",
// "Write a review to help Us know what's good", "send review".
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/order_card_data.dart';
import '../providers/order_repository.dart';
import '../shared/widgets/rating_stars_input.dart';
import 'thank_you_page.dart';

/// Image 6 — buyer rates the store after a successful pickup. The text
/// review is optional and is stored but not displayed anywhere in the app
/// today (store-only field).
class RatingPage extends StatefulWidget {
  final OrderCardData order;

  const RatingPage({super.key, required this.order});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String _initials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase();
  }

  // TODO(copy): confirm exact star labels with user.
  String _labelForRating(int rating) {
    switch (rating) {
      case 1:
        return 'Not good';
      case 2:
        return 'Could be better';
      case 3:
        return 'It was alright';
      case 4:
        return 'Pretty good';
      case 5:
        return 'Excellent!';
      default:
        return ' ';
    }
  }

  void _send() {
    if (_rating == 0) return;
    final reviewText = _reviewController.text.trim();
    OrderRepository().submitRating(
      orderId: widget.order.orderId,
      rating: _rating.toDouble(),
      textReview: reviewText.isEmpty ? null : reviewText,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ThankYouPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final canSend = _rating > 0;

    return Scaffold(
      // TODO(design): confirm exact rating-screen background color
      // (using #FAFCD9 from the spec as the closest match).
      backgroundColor: const Color(0xFFFAFCD9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildCreamHeader(order),
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tell us a little more',
                        style: TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFDEDEDE)),
                        ),
                        child: TextField(
                          controller: _reviewController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: "Write a review to help Us know what's good",
                            hintStyle: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 14,
                              color: Color(0xFFC3C3C3),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(14),
                          ),
                          style: const TextStyle(
                            fontFamily: 'SF Pro Display',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: canSend ? _send : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.secondary,
                            disabledBackgroundColor:
                                AppColors.primary.withValues(alpha: 0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'send review',
                            style: TextStyle(
                              fontFamily: 'SF Pro Display',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreamHeader(OrderCardData order) {
    return ClipPath(
      clipper: _CreamHeaderClipper(),
      child: Container(
        width: double.infinity,
        color: const Color(0xFFFAFCD9),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _CloseButton(
                onTap: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary,
                backgroundImage:
                    (order.storeAvatarUrl != null && order.storeAvatarUrl!.isNotEmpty)
                        ? NetworkImage(order.storeAvatarUrl!)
                        : null,
                child: (order.storeAvatarUrl == null ||
                        order.storeAvatarUrl!.isEmpty)
                    ? Text(
                        _initials(order.storeName),
                        style: const TextStyle(
                          fontFamily: 'SF Pro Display',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'How was your order from\n${order.storeName}?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 24),
            RatingStarsInput(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 22,
              child: Center(
                child: Text(
                  _labelForRating(_rating),
                  style: const TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
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

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.close, color: Colors.black, size: 20),
      ),
    );
  }
}

/// Gives the cream header a subtly dipped bottom edge so it transitions into
/// the white lower section the way the mockup shows.
class _CreamHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 32);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 28,
      0,
      size.height - 32,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
