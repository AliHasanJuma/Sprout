import 'package:flutter/material.dart';

/// Tappable 5-star rating input. The existing display-only `_buildStars`
/// helpers around the app aren't interactive, so this is a new component.
class RatingStarsInput extends StatelessWidget {
  final int value;
  final int maxStars;
  final ValueChanged<int> onChanged;
  final double starSize;
  // TODO(design): confirm the exact star color from the rating mockup.
  final Color filledColor;
  final Color emptyColor;

  const RatingStarsInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.maxStars = 5,
    this.starSize = 44,
    this.filledColor = const Color(0xFFFEA94C),
    this.emptyColor = const Color(0xFFFEA94C),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxStars, (i) {
        final filled = i < value;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: starSize,
              color: filled ? filledColor : emptyColor,
            ),
          ),
        );
      }),
    );
  }
}
