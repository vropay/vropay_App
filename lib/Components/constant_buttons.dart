import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final double width;
  final double height;

  const CommonButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.color = const Color(0xFFEF2D56),
    this.textColor = Colors.white,
    this.width = 333,
    this.height = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
          ),
        ),
        child: child ??
            Text(
              text!,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
      ),
    );
  }
}
