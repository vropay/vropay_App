import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';

import 'back_icon.dart';

class CustomTopNavBar extends StatelessWidget {
  final int? selectedIndex;
  final Function(int)? onItemTap;

  const CustomTopNavBar({
    super.key,
    this.selectedIndex,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    ScreenUtils.setContext(context);
    final List<_NavItem> _items = const [
      _NavItem(imagePath: 'assets/icons/chat.png', label: 'Chat'),
      _NavItem(imagePath: 'assets/icons/library.png', label: 'Library'),
      _NavItem(imagePath: 'assets/icons/launchPad.png', label: 'Launch Pad'),
      _NavItem(imagePath: 'assets/icons/feedback.png', label: 'Feedback'),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 5, right: 27, bottom: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: GestureDetector(
              onTap: () => Get.back(),
              child: BackIcon(),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                final isSelected = index == selectedIndex;

                return GestureDetector(
                  onTap: () => onItemTap?.call(index),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? Color(0xFF006DF4) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFF006DF4)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: ScreenUtils.height * 0.005),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                isSelected ? Colors.white : Color(0xFF006DF4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String imagePath;
  final String label;

  const _NavItem({required this.imagePath, required this.label});
}
