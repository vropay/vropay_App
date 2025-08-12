import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';

import '../../home/controllers/home_controller.dart';

class InterestSelectionDialog extends StatelessWidget {
  final HomeController homeController;
  final RxString selectedValue;

  const InterestSelectionDialog({
    super.key,
    required this.homeController,
    required this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: ScreenUtils.height * 0.02),
            Obx(() => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: homeController.interests.map((topic) {
                    final isSelected =
                        homeController.selectedInterests.contains(topic);
                    return ChoiceChip(
                      label: Text(topic),
                      selected: isSelected,
                      showCheckmark: false,
                      onSelected: (_) => homeController.toggleInterest(topic),
                      selectedColor: const Color(0xFF172B75),
                      backgroundColor: const Color(0xFFEAF1FF),
                      labelStyle: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF172B75),
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    );
                  }).toList(),
                )),
            SizedBox(height: ScreenUtils.height * 0.02),
            ElevatedButton(
              onPressed: () {
                // Close and update selectedValue
                final selected = homeController.selectedInterests.join(', ');
                selectedValue.value = selected.isEmpty ? ' ' : selected;
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEF2D56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                "Done",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
            )
          ],
        ),
      ),
    );
  }
}
