// TODO(i18n): All user-facing strings in this file are English-only. When
// localization is bootstrapped (flutter_localizations + intl + .arb files),
// replace these literals with AppLocalizations lookups. Arabic translations
// needed for: status badge labels ("Pending orders", "Active orders", "Order
// is ready!", "Completed", "Rejected", "Cancelled"), "Delivery details",
// "Total Price", the fallback description text, and the BD currency suffix.
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_card_data.dart';

/// Reusable order card matching the mockups. Used in two places:
///  1. In-chat (read-only, status-driven badge + optional inline actions).
///  2. As the read-only preview on the Pickup Code and Order Pickup screens.
///
/// The editable AI-summarise view consumes the same visual shell but adds its
/// own controls (quantity steppers, delivery edit dialog) — that variant is
/// composed in `AiSummarisePage` rather than baked into this widget.
class OrderCard extends StatelessWidget {
  final OrderCardData order;

  /// Optional buttons rendered INSIDE the card at the bottom (Pending state).
  /// Active/Ready render their CTA outside the card — leave this null then.
  final Widget? actions;

  /// Hide the floating status badge (used on the Pickup screens where the
  /// card is purely informational and the status is implied by the screen).
  final bool showStatusBadge;

  const OrderCard({
    super.key,
    required this.order,
    this.actions,
    this.showStatusBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.only(top: showStatusBadge ? 18 : 0),
          padding: EdgeInsets.fromLTRB(
            18,
            showStatusBadge ? 32 : 20,
            18,
            18,
          ),
          decoration: BoxDecoration(
            color: AppColors.orderCardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < order.items.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(height: 1, color: Color(0xFFE0E0E0)),
                  )
                else
                  const SizedBox.shrink(),
                _OrderItemRow(item: order.items[i]),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1, color: Color(0xFFE0E0E0)),
              ),
              _DeliveryDetailsRow(text: order.deliveryDetails),
              const SizedBox(height: 16),
              _TotalPriceRow(total: order.totalPrice),
              if (actions != null) ...[
                const SizedBox(height: 20),
                actions!,
              ],
            ],
          ),
        ),
        if (showStatusBadge)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(child: _StatusBadge(status: order.status)),
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _styleFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  (Color, Color, String) _styleFor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return (AppColors.pendingBg, AppColors.pendingText, 'Pending orders');
      case OrderStatus.active:
        return (AppColors.activeBg, AppColors.activeText, 'Active orders');
      case OrderStatus.ready:
        return (AppColors.secondary, AppColors.primary, 'Order is ready!');
      case OrderStatus.completed:
        // TODO(design): confirm completed badge colors + label.
        return (AppColors.activeBg, AppColors.activeText, 'Completed');
      case OrderStatus.rejected:
        // TODO(design): confirm rejected badge colors.
        return (AppColors.pendingBg, AppColors.pendingText, 'Rejected');
      case OrderStatus.cancelled:
        // TODO(design): confirm cancelled badge colors.
        return (AppColors.pendingBg, AppColors.pendingText, 'Cancelled');
    }
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItem item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description.isEmpty
                    // TODO(backend): pull real description from products/shelves.
                    ? 'Here the seller place the description of the product'
                    : item.description,
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 13,
                  height: 1.3,
                  color: Color(0xFF9F9F9F),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),
              Text(
                '${item.lineTotal.toStringAsFixed(1)} BD',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // TODO(backend): swap placeholder for Image.network(item.imageUrl).
        Container(
          width: 110,
          height: 130,
          decoration: BoxDecoration(
            color: AppColors.imagePlaceholder,
            borderRadius: BorderRadius.circular(12),
          ),
          child: item.imageUrl == null
              ? null
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
        ),
      ],
    );
  }
}

class _DeliveryDetailsRow extends StatelessWidget {
  final String text;

  const _DeliveryDetailsRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.inventory_2_outlined,
          size: 26,
          color: Colors.black,
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
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text.isEmpty
                    // TODO(backend): join from stores/{storeId}.defaultDeliveryDetails.
                    ? 'Here the seller place the description of the\nDelivery of the product'
                    : text,
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 13,
                  height: 1.3,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TotalPriceRow extends StatelessWidget {
  final double total;

  const _TotalPriceRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.local_offer_outlined,
          size: 26,
          color: Colors.black,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${total.toStringAsFixed(1)} BD',
                style: const TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
