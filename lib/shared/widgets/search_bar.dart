import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onSubmitted;
  // Figma spec: "Search for anything", 13 px, #C3C3C3
  final String hintText;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onSubmitted,
    this.hintText = 'Search for anything',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(70),
        boxShadow: const [
          BoxShadow(
            // 0px 3px 20px -8px rgba(0,0,0,0.25)
            color: Color.fromRGBO(0, 0, 0, 0.25),
            offset: Offset(0, 3),
            blurRadius: 20,
            spreadRadius: -8,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFC3C3C3),
            fontFamily: 'SF Pro Display',
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF003E3B),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
