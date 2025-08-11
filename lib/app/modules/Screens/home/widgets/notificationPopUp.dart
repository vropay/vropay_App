import 'package:flutter/material.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';

import '../../../../../Components/back_icon.dart';

class NotificationScreen extends StatelessWidget {
  final VoidCallback onFinish;

  const NotificationScreen({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    ScreenUtils.setContext(context);
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: BackIcon(),
            ),
            Image.asset(
              'assets/images/notification.png',
              height: 183,
              width: 145,
            ),
            SizedBox(height: ScreenUtils.height * 0.02),
            Text(
              'Notification',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w300,
                color: Color(0xFF172B75),
              ),
            ),
            SizedBox(height: ScreenUtils.height * 0.01),
            Text(
              'nudges to keep you\n sharp and moving forward',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color(0x8F172B75).withOpacity(0.5),
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(height: ScreenUtils.height * 0.02),
            SizedBox(
              width: 250,
              child: ElevatedButton(
                onPressed: onFinish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(28),
                      ),
                      side: BorderSide(color: Color(0xFFEF2D56), width: 0.4)),
                ),
                child: const Text(
                  "Turn on",
                  style: TextStyle(
                      color: Color(0xFFEF2D56),
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: ScreenUtils.height * 0.02),
            GestureDetector(
              onTap: onFinish,
              child: Text(
                "Skip for now",
                style: TextStyle(
                    color: Color(0xFFEF2D56),
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFEF2D56)),
              ),
            ),
            SizedBox(height: ScreenUtils.height * 0.04),
          ],
        ),
      ),
    );
  }
}
