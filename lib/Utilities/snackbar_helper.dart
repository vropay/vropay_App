
import 'package:flutter/material.dart';
import 'package:get/get.dart';


void setSnackBar(String title, String message,
    {int seconds = 3,
      SnackPosition? position,
      bool? progressIndicator,
      bool? dismissible,
      Widget? icon,
      Color? backgroundColor,
      LinearGradient? gradient,
      bool? pulse}) {
  Get.snackbar(title, message,
      duration: Duration(seconds: seconds),
      snackPosition: position,
      shouldIconPulse: pulse,
      margin: const EdgeInsets.all(10),
      isDismissible: dismissible,
      backgroundGradient: gradient,
      colorText: Colors.black,
      icon: icon,
      titleText: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 12
        ),
      ),
      showProgressIndicator: progressIndicator,
      snackStyle: SnackStyle.FLOATING);
}
