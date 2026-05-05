import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../buyer_ui/Mainscreen.dart';
import '../services/seller_service.dart';

Future<void> showDeleteStoreDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Delete your store?',
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      content: const Text(
        'This will permanently remove your store, all shelves, and your listings from Sprout. This action cannot be undone.',
        style: TextStyle(
          fontFamily: 'SF Pro Display',
          fontSize: 14,
          color: Color(0xFF6B6B6B),
          height: 1.4,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, false),
          style: TextButton.styleFrom(
            overlayColor: const Color(0xFFBDBDBD),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, true),
          style: TextButton.styleFrom(
            overlayColor: const Color(0xFFBDBDBD),
          ),
          child: const Text(
            'Delete store',
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD64545),
            ),
          ),
        ),
      ],
    ),
  );

  if (confirmed != true) return;
  if (!context.mounted) return;

  await SellerService().deleteStore();
  if (!context.mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const MainScreen(initialIndex: 3)),
    (_) => false,
  );
}
