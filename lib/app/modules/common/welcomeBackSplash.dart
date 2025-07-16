import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';

class WelcomeBackSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Get.offNamed(Routes.OTP_SCREEN);
    });

    return Scaffold(
      body: Center(child: Text('Welcome back!')),
    );
  }
}
