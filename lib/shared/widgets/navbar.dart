import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary, // Neon green background
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80, // Fixed height for navbar
          padding: const EdgeInsets.symmetric(horizontal: 4), //  padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, 'Home', 'assets/UI icons package/PNG/Black/Navigation/House_01.png'),
              _buildNavItem(1, 'Chat', 'assets/UI icons package/PNG/Black/Communication/Chat_Circle_Dots.png'),
              _buildNavItem(2, 'Favourite', 'assets/UI icons package/PNG/Black/Interface/Heart_01.png'),
              _buildNavItem(3, 'Shelves', 'assets/UI icons package/PNG/Black/Interface/Shopping_Bag_02.png'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String iconPath) {
    final isSelected = currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4), //  vertical padding
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isSelected 
                ? AppColors.secondary.withValues(alpha: 0.2)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon 
              Image.asset(
                iconPath,
                width: 32, // Size
                height: 32, // Size
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 2), // Reduced space
              // Label - with original colors only
              Text(
                label,
                style: TextStyle(
                  fontSize: 11, // Slightly smaller
                  fontFamily: 'SF Pro Display',
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected 
                      ? AppColors.secondary // Dark green for selected
                      : Colors.black, // Black for unselected
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}