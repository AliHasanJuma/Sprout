import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/buyer_ui/Mainscreen.dart';
import '../shelf/create_shelf_page.dart';

class SellerSuccessPage extends StatelessWidget {
  const SellerSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Image.asset(
                'assets/icons/Seller_picture.png',
                width: 135,
                height: 135,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 32),
              const Text(
                'Congratulations,\nyou\'re a Seller!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your shop is live and ready to grow. Start adding products to show the community what you\u2019ve got.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF9F9F9F),
                  fontSize: 14,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                ),
              ),
              const Spacer(flex: 2),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateShelfPage(),
                    ),
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
                      'Add Product',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 16,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainScreen(initialIndex: 0),
                    ),
                    (r) => false,
                  );
                },
                child: const Text(
                  'I\'ll do this later, take me home',
                  style: TextStyle(
                    color: Color(0xFF9F9F9F),
                    fontSize: 14,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
