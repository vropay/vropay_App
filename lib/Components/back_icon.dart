import 'package:flutter/material.dart';

class BackIcon extends StatelessWidget {
  final Color color;
  final bool isInsideButton; // Add this parameter
  final VoidCallback? onTap;

  const BackIcon(
      {super.key,
      this.color = const Color(0xFFFFA000),
      this.isInsideButton =
          false, // Default to false for backward compatibility
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      Icons.arrow_back_ios_new_outlined,
      color: color,
      size: 24,
    );

    // If it's inside a button, don't wrap with GestureDetector
    if (isInsideButton) {
      return icon;
    }

    // Otherwise, wrap with GestureDetector for standalone use
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: icon,
    );
  }
}
