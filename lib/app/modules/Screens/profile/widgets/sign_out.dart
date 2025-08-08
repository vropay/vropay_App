import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components/back_icon.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class SignOutDialog extends StatelessWidget {
  const SignOutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: BackIcon(),
            ),
            const SizedBox(height: 12),

            // Centered Rich Text
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5F5F73),
                  height: 1.6,
                ),
                children: [
                  TextSpan(text: "you're about to "),
                  TextSpan(
                    text: 'sign out',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E38),
                    ),
                  ),
                  TextSpan(text: "\nfrom this device\n"),
                  TextSpan(text: "you can sign back in from\nany device, anytime"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Image.asset('assets/images/signout.png',
              height: 150,
            ),
            SizedBox(height: 10,),
            Image.asset('assets/images/seeya.png',
              height: 40,
            ),

            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular( 20
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SizedBox(
                width: 250,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Get.toNamed(Routes.SIGNOUT_SCREEN);
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => Get.back(), // Close dialog
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.redAccent,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.redAccent,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
