import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFDAF64F);   // Neon Green
  static const secondary = Color(0xFF003E3B); // Dark Green
  static const tertiary = Color(0xFFEFF8C5);  // Light Lime
  static const background = Colors.white;

  // ── Order card status badges ──
  static const pendingBg = Color(0xFFFFEFDE);
  static const pendingText = Color(0xFFFEA94C);
  static const activeBg = Color(0xFFD9FFE4);
  static const activeText = Color(0xFF00CD3B);
  // ready badge reuses secondary (bg) + primary (text)

  // ── Misc tokens ──
  static const imagePlaceholder = Color(0xFFE5E5E5);
  static const orderCardBg = Color(0xFFF5F5F5); // light grey card surface

  // TODO(design): confirm cancelled badge colors (using pending palette for now)
  // TODO(design): confirm rejected badge colors (using pending palette for now)
}
