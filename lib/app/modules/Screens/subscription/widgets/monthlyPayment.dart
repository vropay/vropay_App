import 'package:flutter/material.dart';

class SubscriptionDialog extends StatelessWidget {
  final VoidCallback onMonthly;
  final VoidCallback onAnnual;
  final VoidCallback onBack;

  const SubscriptionDialog({
    super.key,
    required this.onMonthly,
    required this.onAnnual,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Back Button
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.orange),
                onPressed: onBack,
              ),
            ),

            // Image
            Image.asset(
              'assets/images/monthly.png',
              height: 150,
            ),

            const SizedBox(height: 20),

            const Text(
                'wanna keep paying monthly on autopay ?\nOr switch to a cheaper,\none-time yearly plan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF006DF4),
                  height: 1.5,
                ),
              ),

            const SizedBox(height: 24),

            // Monthly Button
            _buildRedButton(
              label: "pay for monthly autopay\nsubscription",
              onPressed: onMonthly,
            ),

            const SizedBox(height: 14),

            // Annual Button
            _buildRedButton(
              label: "Go for annual",
              onPressed: onAnnual,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRedButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEF2D56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(double.infinity, 55),
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      child: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
              child: const Icon(Icons.double_arrow_rounded, color: Colors.white)),
          Flexible(
            child: Center(
              child: Text(
                textAlign: TextAlign.center,
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
