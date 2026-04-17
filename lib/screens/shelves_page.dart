import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'create_shop_page.dart';

class ShelvesPage extends StatelessWidget {
  const ShelvesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // Seller Image
              Center(
                child: Image.asset(
                  'assets/icons/Seller_picture.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
              
              
              // Title
              const Center(
                child: Text(
                  'Become a Seller',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Feature 1: Turn Passion into Profit
              _buildFeatureRow(
                icon: Icons.local_fire_department_outlined,
                title: 'Turn Passion into Profit',
                subtitle: 'Monetize your skills with a fast, easy setup.',
              ),
              
              const SizedBox(height: 38),
              
              // Feature 2: Instant Audience Access
              _buildFeatureRow(
                icon: Icons.people_outline,
                title: 'Instant Audience Access',
                subtitle: 'Tap into an active community ready to buy.',
              ),
              
              const SizedBox(height: 38),
              
              // Feature 3: Powerful Seller Tools
              _buildFeatureRow(
                icon: Icons.auto_awesome_outlined,
                title: 'Powerful Seller Tools',
                subtitle: 'Track sales and manage orders effortlessly.',
              ),
              
              const SizedBox(height: 72),
              
              // Launch Your Shop Button
              Center(
                child: GestureDetector(
                  onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateShopPage()),
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
                          color: Color(0xFF003E3B),
                          fontSize: 16,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                color: AppColors.secondary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF636363),
                    fontSize: 14,
                    fontFamily: 'SF Pro Display',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9F9F9F),
                    fontSize: 12,
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