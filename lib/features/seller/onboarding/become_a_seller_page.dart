import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import 'create_your_shop_page.dart';

class BecomeASellerPage extends StatelessWidget {
  const BecomeASellerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = screenHeight * 0.10;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: topPadding),

              // ── Block 1: icon + title as a tight pair ──
              Image.asset(
                'assets/icons/Seller_picture.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              const Text(
                'Become a seller',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 72),

              // ── Block 2: three feature rows, evenly spaced ──
              _buildFeatureRow(
                iconAsset: 'assets/Becpme a seller icons/fire.svg',
                title: 'Turn Passion into Profit',
                subtitle: 'Monetize your skills with a fast, easy setup.',
              ),
              const SizedBox(height: 32),
              _buildFeatureRow(
                iconAsset: 'assets/Becpme a seller icons/Audience.svg',
                title: 'Instant Audience Access',
                subtitle: 'Tap into an active community ready to buy.',
              ),
              const SizedBox(height: 32),
              _buildFeatureRow(
                iconAsset: 'assets/Becpme a seller icons/Tools.svg',
                title: 'Powerful Seller Tools',
                subtitle: 'Track sales and manage orders effortlessly.',
              ),

              const SizedBox(height: 72),

              // ── Block 3: CTA button ──
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateYourShopPage(),
                    ),
                  );
                },
                child: Container(
                  width: 338,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(70),
                  ),
                  child: const Center(
                    child: Text(
                      'Launch Your Shop',
                      textAlign: TextAlign.center,
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

              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required String iconAsset,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(iconAsset, width: 40, height: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9F9F9F),
                    fontSize: 13,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
