import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class GoodbyeOverlayWidget extends StatelessWidget {
  const GoodbyeOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Get.offAllNamed(Routes.ON_BOARDING);
    });

    return Material(
      color: Colors.white.withOpacity(0.6),
      child: Stack(
        children: [
          // Centered Circle Text
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.redAccent,
                  width: 25,
                ),
              ),
              child: const Center(
                child: Text(
                  'bye.',
                  style: TextStyle(
                    fontSize: 40,
                    color: Color(0xFF001242),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Bottom Image
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/vropayLogo.png',
                height: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
