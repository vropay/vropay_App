import 'package:flutter/material.dart';

import '../../../../../Components /back_icon.dart';

class FreePopUp extends StatelessWidget {
  final VoidCallback onYesPressed;
  final VoidCallback onSkipPressed;

  const FreePopUp({
    required this.onYesPressed,
    required this.onSkipPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(alignment: Alignment.centerLeft, child: BackIcon()),
            Image.asset('assets/images/PoPUpSubscription.png', height: 112, width: 120),
            const SizedBox(height: 10),
            const Text(
              'really?',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172B75),
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'only 1,000 spots..\n',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  TextSpan(
                    text: '₹ 1122 to unlock it all\ndo you want to miss?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF006DF4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: onYesPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF2D56),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                ),
                child: const Text(
                  "Yes, I want to be in",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onSkipPressed,
              child: const Text(
                "Skip for now",
                style: TextStyle(
                  color: Color(0xFFEF2D56),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFEF2D56),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
