import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SellerSettingsRow extends StatelessWidget {
  final String iconAsset;
  final String label;
  final Color labelColor;
  final Color chevronColor;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const SellerSettingsRow({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.labelColor = AppColors.secondary,
    this.chevronColor = const Color(0xFFBFBFBF),
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Image.asset(
              iconAsset,
              width: 22,
              height: 22,
              color: labelColor,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'SF Pro Display',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ),
            Image.asset(
              'assets/UI icons package/PNG/Black/Arrow/Chevron_Right.png',
              width: 18,
              height: 18,
              color: chevronColor,
            ),
          ],
        ),
      ),
    );
  }
}
