import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const SocialButton({
    Key? key,
    required this.text,
    required this.iconPath,
    this.borderColor = Colors.black,
    this.textColor = Colors.black,
    this.width = 343, // Default full width
    this.height = 56,
    required this.onPressed,
  }) : super(key: key);

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
            Text(text, style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}
