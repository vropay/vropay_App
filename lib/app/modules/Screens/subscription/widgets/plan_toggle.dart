import 'package:flutter/material.dart';

class PlanToggleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const PlanToggleButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.85,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(25),
            topLeft: Radius.circular(11),
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(11),
          ),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFFEF2D56),
                fontSize: 15
              ),
            ),
            Row(
              children: [
                Text(
                  'proceed',
                  style: TextStyle(
                    color: Color(0xFF172B75),
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                    width: 30,
                    height: 30,
                    color: Color(0xFF172B75),
                    child: const Icon(Icons.arrow_forward, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
