import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_pages.dart';

class FirstTimeSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 2), () {
      Get.offNamed(Routes.ON_BOARDING);
    });

    return Scaffold(
      body: Center(child: Image.asset('assets/images/vropaylogo.png')),
    );
  }
}
