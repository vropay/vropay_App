import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';

class InterestSelectionDialog extends StatelessWidget {
  final HomeController homeController;
  final RxString selectedValue;

  const InterestSelectionDialog({
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
            const SizedBox(height: 12),
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
                        fontSize: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    );
                  }).toList(),
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Close and update selectedValue
                final selected = homeController.selectedInterests.join(', ');
                selectedValue.value = selected.isEmpty ? ' ' : selected;
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF2D56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                "Done",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
