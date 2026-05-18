import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int? maxLength;
  final bool countOnlyNonSpace; // NEW - to control counting method

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator,
    this.maxLength,
    this.countOnlyNonSpace = false, // NEW - defaults to false for backward compatibility
  });

  // Helper to get the actual character count based on settings
  int _getCharacterCount(String text) {
    if (countOnlyNonSpace) {
      // Count only non-space characters
      return text.replaceAll(' ', '').length;
    }
    // Count all characters (including spaces)
    return text.length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'SF Pro Display',
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Color(0xFF003E3B),
              ),
            ),
            // Only show counter if maxLength is provided
            if (maxLength != null && controller != null)
              StreamBuilder<String?>(
                stream: _getTextStream(),
                builder: (context, snapshot) {
                  final currentLength = _getCharacterCount(controller?.text ?? '');
                  return Text(
                    '$currentLength/$maxLength',
                    style: TextStyle(
                      fontFamily: 'SF Pro Display',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: currentLength >= maxLength! 
                          ? Colors.red 
                          : const Color(0xFF9F9F9F),
                    ),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLength: maxLength,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
            // Return null to hide the default Flutter counter
            return null;
          },
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFFC3C3C3)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDEDEDE), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDAF64F), width: 1.0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDEDEDE), width: 1.0),
            ),
          ),
        ),
      ],
    );
  }

  // Helper to get text changes stream for real-time counter
  Stream<String?> _getTextStream() async* {
    if (controller != null) {
      yield controller!.text;
      await for (var _ in Stream.periodic(const Duration(milliseconds: 100))) {
        yield controller!.text;
      }
    }
  }
}