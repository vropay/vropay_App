import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final Color borderColor;
  final Color textColor;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  const SocialButton({
    super.key,
    required this.text,
    required this.iconPath,
    this.borderColor = Colors.black,
    this.textColor = Colors.black,
    this.width = 343, // Default full width
    this.height = 56,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          side: BorderSide(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(iconPath, height: 20),
            const SizedBox(width: 10),
            Text(text,
                style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
