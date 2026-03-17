import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onSubmitted;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Search for something',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontFamily: 'SF Pro Display',
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.secondary,
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}