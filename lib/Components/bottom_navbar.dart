// widgets/custom_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/modules/common/controller/bottom_navbar_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<BottomNavController>();

    final List<String> defaultIcons = const [
      'assets/icons/home.png',
      'assets/icons/profile.png',
      'assets/icons/learn.png',
      'assets/icons/bagIcon.png',
      'assets/icons/bellIcon.png',
    ];

    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dynamic text label above navigation bar
                Container(
                  padding: const EdgeInsets.only(bottom: 0, top: 8),
                  child: _buildDynamicLabel(navController.currentIndex.value),
                ),

                // Navigation bar (existing Row)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(defaultIcons.length, (index) {
                    final isSelected =
                        index == navController.currentIndex.value;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                            icon: Image.asset(
                              defaultIcons[index],
                              color: isSelected
                                  ? Color(0xFF004AAC)
                                  : Color(0xFFC4C7D5),
                              height: 20,
                            ),
                            onPressed: () {
                              if (index == 1) {
                                navController.setSubOption('primary');
                                navController.updateIndex(index);
                                Get.toNamed('/profile/primary');
                              } else if (index == 2) {
                                navController.setSubOption('learn');
                                navController.updateIndex(index);
                                Get.toNamed('/learn-screen');
                              } else {
                                navController.updateIndex(index);
                                switch (index) {
                                  case 0:
                                    Get.toNamed('/dashboard');
                                    break;
                                  case 3:
                                    Get.toNamed('/shop');
                                    break;
                                  case 4:
                                    Get.toNamed('/notifications');
                                    break;
                                }
                              }
                            }),
                        if (isSelected && index == 4)
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFFC4C7D5),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        if (isSelected && index == 2)
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFFC4C7D5),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        if (isSelected && index == 1)
                          Positioned(
                            top: 14,
                            right: 19,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Color(0xFFC4C7D5),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _optionSelector(List<String> options, void Function(String) onSelect) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: options
          .map((opt) => ListTile(
                title: Text(
                  opt,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => Get.back(),
              ))
          .toList(),
    );
  }

  Widget _buildDynamicLabel(int selectedIndex) {
    switch (selectedIndex) {
      case 0: // Home
        return const Text(
          'home',
          style: TextStyle(
            color: Color(0xFF004AAC),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        );
      case 1: // Profile
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'primary ',
                style: TextStyle(
                  color: Color(0xFF004AAC),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: 'social',
                style: TextStyle(
                  color: Color(0xFF004AAC).withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      case 2: // Learn
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'learn ',
                style: TextStyle(
                  color: Color(0xFF004AAC),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: 'hustle',
                style: TextStyle(
                  color: Color(0xFF004AAC).withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      case 3: // Shop
        return const Text(
          'shop',
          style: TextStyle(
            color: Color(0xFF004AAC),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        );
      case 4: // Notifications
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'source',
              style: TextStyle(
                color: Color(0xFF004AAC),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_up,
              color: Color(0xFFFABAC7),
              size: 20,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
