import 'package:flutter/material.dart';

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
      decoration: const BoxDecoration(
        color: Colors.white,
        // Lighter shadow matching Figma: ~15% opacity, soft upward blur
        boxShadow: [
          BoxShadow(
            color: Color(0x26000000), // 15% black
            offset: Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 86,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                0,
                'Home',
                iconPath: 'assets/UI icons package/PNG/Black/Navigation/House_01.png',
              ),
              _buildNavItem(
                1,
                'Chat',
                iconPath: 'assets/UI icons package/PNG/Black/Communication/Chat_Circle_Dots.png',
              ),
              _buildNavItem(
                2,
                'Favourite',
                iconPath: 'assets/UI icons package/PNG/Black/Interface/Heart_01.png',
              ),
              // Shelves icon from assets
              _buildNavItem(
                3,
                'Shelves',
                iconPath: 'assets/UI icons package/PNG/Black/Edit/Rows.png',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label, {
    String? iconPath,
    IconData? iconData,
  }) {
    final isActive = currentIndex == index;
    // Active: black (#000000), Inactive: grey (#9F9F9F)
    final color = isActive ? Colors.black : const Color(0xFF9F9F9F);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use Icon widget if iconData provided, otherwise Image.asset
            if (iconData != null)
              Icon(iconData, size: 24, color: color)
            else if (iconPath != null)
              Image.asset(
                iconPath,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                color: color,
                colorBlendMode: BlendMode.srcIn,
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 11,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
