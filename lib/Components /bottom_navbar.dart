import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> defaultIcons = const [
      'assets/icons/home.png',
      'assets/icons/profile.png',
      'assets/icons/giftIcon.png',
      'assets/icons/bagIcon.png',
      'assets/icons/bellIcon.png',
    ];

    return Container(
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
            final isSelected = index == currentIndex;
            return IconButton(
              icon: Image.asset(
                defaultIcons[index],
                color: isSelected ? Color(0xFF00B8F0) : Color(0xFF006DF4),
                width: 20,
                height: 24,
              ),
              onPressed: () => onTap!(index),
            );
          }),
        ),
      ),
    );
  }
}
