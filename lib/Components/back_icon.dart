import 'package:flutter/material.dart';
import 'package:get/get.dart'; // if using GetX for navigation

class BackIcon extends StatelessWidget {
  final VoidCallback? onTap;
  final Color color;

  const BackIcon({super.key, this.onTap, this.color = const Color(0xFFFFA000)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Get.back(),
      child: const Icon(
        Icons.arrow_back_ios_new_outlined,
        color: Color(0xFFFFA000),
        size: 24,
      ),
    );
  }
}
