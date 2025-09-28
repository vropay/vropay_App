import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';

import '../../../../../Components/back_icon.dart';
import '../controllers/home_controller.dart';

class CommunityAccessScreen extends StatelessWidget {
  final VoidCallback onNext;

  const CommunityAccessScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    ScreenUtils.setContext(context);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: BackIcon(
                onTap: () {
                  if (controller.currentStep.value > 0) {
                    controller.currentStep.value--;
                  } else {
                    Get.back();
                  }
                },
              ),
            ),
            Image.asset(
              'assets/images/communityAccess.png',
              height: 167,
              width: 185,
            ),
            SizedBox(height: ScreenUtils.height * 0.02),
            Text(
              'Community Access',
              style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF172B75)),
            ),
            Text(
              'for the topics selected',
              style: TextStyle(
                  color: Color(0x8F172B75).withOpacity(0.5),
                  fontSize: 14,
                  decoration: TextDecoration.underline),
            ),
            SizedBox(height: ScreenUtils.height * 0.02),
            Obx(() {
              final selected = controller.selectedCommunityAccess
                  .value; // used below for border highlight
              return Column(
                children: [
                  _buildOption(
                    "Join & Interact",
                    "with the community",
                    selected,
                    controller,
                  ),
                  _buildOption(
                    "Just Scroll",
                    "to read the conversations",
                    selected,
                    controller,
                  ),
                ],
              );
            }),
            SizedBox(height: ScreenUtils.height * 0.02),
            GestureDetector(
              onTap: onNext,
              child: const Text(
                "Continue",
                style: TextStyle(
                    color: Color(0xFFEF2D56),
                    fontSize: 17,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFFEF2D56)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    String title,
    String description,
    String? selectedOption,
    HomeController controller,
  ) {
    final bool selected = selectedOption == title; // emphasize with border

    // Choose background based on title
    final Color bgColor = title.contains("Join")
        ? const Color(0xFFFFE6EB) // Light pink
        : const Color(0xFFDFF0FF); // Light blue

    return GestureDetector(
      onTap: () => controller.updateCommunityAccess(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: const Color(0xFF172B75), width: 1)
              : null,
        ),
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 15,
                fontFamily: 'Inter',
                color: Colors.black87,
              ),
              children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Color(0xFF172B75),
                  ),
                ),
                TextSpan(
                  text: ' $description',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF172B75),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
