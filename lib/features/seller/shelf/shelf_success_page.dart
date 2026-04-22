import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/buyer_ui/Mainscreen.dart';
import '../widgets/seller_app_bar.dart';

class ShelfSuccessPage extends StatelessWidget {
  const ShelfSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const SellerAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Image.asset(
                'assets/icons/Digital_shelf.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              const Text(
                'Your Shelf is Live!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Great work! Your product is officially planted in the Sprout community and ready for its first buyer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9F9F9F),
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                ),
              ),
              const Spacer(flex: 3),
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainScreen(initialIndex: 3),
                    ),
                    (r) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(70),
                  ),
                  child: const Center(
                    child: Text(
                      'View My Store',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 16,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
