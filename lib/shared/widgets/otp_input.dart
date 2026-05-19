import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

/// Reusable N-box OTP / pickup-code input. Used by phone-auth verification
/// (6 boxes) and the buyer pickup-code entry screen (4 boxes).
class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final double boxWidth;
  final double boxHeight;

  const OtpInput({
    super.key,
    required this.length,
    this.onChanged,
    this.onCompleted,
    this.boxWidth = 45,
    this.boxHeight = 55,
  });

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  /// Public API: clear all boxes and refocus the first one. Used by the
  /// pickup screen after a wrong code is entered.
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
    widget.onChanged?.call('');
  }

  String get value =>
      _controllers.map((c) => c.text).join();

  void _handleChanged(int index, String v) {
    if (v.length > 1) {
      // Defensive: paste into a single box should land on the first digit.
      _controllers[index].text = v.characters.first;
    }
    if (v.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    final full = value;
    widget.onChanged?.call(full);
    // Every box has maxLength: 1, so when the joined string equals widget.length
    // every position holds exactly one digit and the input is complete.
    // (Don't use `!full.contains('')` — `String.contains('')` is always true.)
    final allFilled = _controllers.every((c) => c.text.length == 1);
    if (full.length == widget.length && allFilled) {
      widget.onCompleted?.call(full);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return Container(
          width: widget.boxWidth,
          height: widget.boxHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDEDEDE)),
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            onChanged: (v) => _handleChanged(index, v),
          ),
        );
      }),
    );
  }
}
