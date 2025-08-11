import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';

class SimpleSplashExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Auto-navigate after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Get.offNamed(Routes.ON_BOARDING);
    });

    return Scaffold(
      backgroundColor: Color(0xFF172B75), // Your app's primary color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with scale animation
            TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 1500),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/images/vropayLogo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 40),

            // App name with fade animation
            TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 2000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    'VRoPay',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 20),

            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),

            SizedBox(height: 30),

            // Loading text
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
