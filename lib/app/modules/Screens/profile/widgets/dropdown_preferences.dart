import 'package:flutter/material.dart';
import 'dart:ui'; // Add this import
import 'package:get/get.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import '../controllers/profile_controller.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';

class DropdownPreference extends StatelessWidget {
  final String label;
  final List<String> options;
  final RxString selectedValue;
  final String iconPath;

  const DropdownPreference({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.iconPath,
  });

  void _showCustomDropdown(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
            button.localToGlobal(Offset.zero),
            button.localToGlobal(button.size.bottomRight(Offset.zero),
                ancestor: overlay)),
        Offset.zero & overlay.size);

    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Blurred background - covers entire screen
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 8.0, sigmaY: 8.0), // Increased blur
                child: GestureDetector(
                  onTap: () {
                    overlayEntry?.remove();
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5), // Increased opacity
                  ),
                ),
              ),
            ),
            // Dropdown menu
            Positioned(
              top: 400,
              right: 10,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: ScreenUtils.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((String choice) {
                      final bool isSelected = selectedValue.value == choice;
                      return InkWell(
                        onTap: () async {
                          selectedValue.value = choice;
                          // Call controller method if this is gender selection
                          if (label == 'Gender') {
                            final profileController =
                                Get.find<ProfileController>();
                            profileController.updateGender(choice);
                          }
                          overlayEntry?.remove();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEAF1FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                choice,
                                style: const TextStyle(
                                  color: Color(0xFF616161),
                                  fontSize: 14,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Colors.redAccent, size: 18),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              // Left side: Icon and label
              Row(
                children: [
                  Image.asset(
                    iconPath,
                    width: 20,
                    height: 20,
                    color: Color(0xFF4D84F7),
                  ),
                  SizedBox(width: ScreenUtils.width * 0.04),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF172B75),
                    ),
                  ),
                ],
              ),
              SizedBox(width: ScreenUtils.width * 0.2),

              // Right side: selected value and dropdown button
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: GestureDetector(
                  onTap: () => _showCustomDropdown(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedValue.value.isEmpty ? ' ' : selectedValue.value,
                        style: const TextStyle(
                            color: Color(0xFF616161),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(width: ScreenUtils.width * 0.02),
                      Icon(Icons.keyboard_arrow_down_sharp,
                          color: Color(0xFF4D84F7)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
