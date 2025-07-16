import 'package:flutter/material.dart';

class CurvedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const CurvedTextField({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SmoothConvexClipper(),
      child: Container(
        height: MediaQuery.of(context).size.width * 0.14,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Center(
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF172B75)
            ),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Color(0xFF172B75),
                fontSize: 16
              )
            ),
          ),
        ),
      ),
    );
  }
}

class SmoothConvexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final curveHeight = 8.0;
    final cornerRadius = 12.0;

    final path = Path();

    // Start with a rounded top-left corner
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // Top convex curve
    path.quadraticBezierTo(
      size.width * 0.33, curveHeight,
      size.width * 0.5, curveHeight,
    );
    path.quadraticBezierTo(
      size.width * 0.67, curveHeight,
      size.width - cornerRadius, 0,
    );

    // Top-right corner
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // Right side down
    path.lineTo(size.width, size.height - cornerRadius);

    // Bottom-right corner
    path.quadraticBezierTo(
      size.width, size.height,
      size.width - cornerRadius, size.height,
    );

    // Bottom convex curve
    path.quadraticBezierTo(
      size.width * 0.67, size.height - curveHeight,
      size.width * 0.5, size.height - curveHeight,
    );
    path.quadraticBezierTo(
      size.width * 0.33, size.height - curveHeight,
      cornerRadius, size.height,
    );

    // Bottom-left corner
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
