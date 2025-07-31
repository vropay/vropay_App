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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(defaultIcons.length, (index) {
            final isSelected = index == navController.currentIndex.value;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: Image.asset(
                    defaultIcons[index],
                    color: isSelected ? Color(0xFF00B8F0) : Color(0xFF006DF4),
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
                    }
                ),
                // Red dot on selected
                if (isSelected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          }),
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
}
