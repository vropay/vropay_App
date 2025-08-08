import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Components/back_icon.dart';
import '../../../../../Components/outlinedConstantButton.dart';
import '../../../../../Utilities/constants/KImages.dart';
import '../controllers/home_controller.dart';

class DifficultyLevelScreen extends StatelessWidget {
  final VoidCallback onNext;

  const DifficultyLevelScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final HomeController controller = Get.find<HomeController>();

    return Dialog(
      backgroundColor: Color(0xFFF7F7F7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: BackIcon(),
            ),
            Image.asset(KImages.difficultyImage, height: 200, width: 170),
            SizedBox(
              width: screenWidth * 0.95,
            ),
            const Text(
              'Select the difficulty level\n for your feed',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w300,
                color: Color(0xFF172B75),
              ),
            ),
            const SizedBox(height: 20),

            Obx(() => Column(
              children: ['Beginner', 'Moderate', 'Advance']
                  .asMap()
                  .entries
                  .map(
                    (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: CustomFilledButton(
                    text: entry.value,
                    isSelected: controller.selectedLevel.value == entry.value,
                    isDifferent: entry.key == 1,
                    onPressed: () => controller.selectLevel(entry.value),
                  ),
                ),
              )
                  .toList(),
            )),


            const SizedBox(height: 10),
            GestureDetector(
              onTap: onNext,
              child: const Text(
                "Continue",
                style: TextStyle(color: Color(0xFFEF2D56),
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
}
