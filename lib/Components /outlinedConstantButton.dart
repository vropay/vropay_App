import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isDifferent;
  final VoidCallback onPressed;

  const CustomFilledButton({
    Key? key,
    required this.text,
    required this.isSelected,
    this.isDifferent = false,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;

    if (isSelected) {
      if (isDifferent) {
        backgroundColor = const Color(0xFFE3F2FF); // Light blue for "Moderate"
      } else if (text.toLowerCase() == "advance") {
        backgroundColor = const Color(0xFFFFEBEE); // Light pink for "Advance"
      } else {
        backgroundColor = const Color(0xFFEFEFEF); // Light gray for "Beginner"
      }
    } else {
      backgroundColor = const Color(0xFFF7F7F7); // Default background
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text.toLowerCase(),
            style: const TextStyle(
              color: Color(0xFF172B75),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
