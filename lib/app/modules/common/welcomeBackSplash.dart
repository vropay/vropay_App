import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';

class WelcomeBackSplashScreen extends StatelessWidget {
  const WelcomeBackSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String firstName = Get.arguments['firstName'] ?? 'User';

    // Auto navigate to dashboard after showing greeting
    Timer(Duration(seconds: 2), () {
      Get.offAllNamed(Routes.DASHBOARD);
    });

    return Scaffold(
      body: Row(
        children: [
          Center(child: Text('Welcome back!')),
          SizedBox(
            width: 8,
          ),
          Text(
            firstName,
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
