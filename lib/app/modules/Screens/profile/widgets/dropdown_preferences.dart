import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DropdownPreference extends StatelessWidget {
  final String label;
  final List<String> options;
  final RxString selectedValue;
  final String iconPath;

  const DropdownPreference({
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Icon and label
          Row(
            children: [
              Image.asset(
                iconPath,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172B75),
                ),
              ),
            ],
          ),

          // Right side: selected value and dropdown button
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: Colors.white,
            onSelected: (value) {
              selectedValue.value = value;
            },
            itemBuilder: (BuildContext context) {
              return options.map((String choice) {
                final bool isSelected = selectedValue.value == choice;
                return PopupMenuItem<String>(
                  value: choice,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFEAF1FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          choice,
                          style: const TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: Colors.redAccent, size: 18),
                      ],
                    ),
                  ),
                );
              }).toList();
            },

            child: Row(
              children: [
                Text(
                  selectedValue.value.isEmpty ? ' ' : selectedValue.value,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_sharp, color: Color(0xFF83A5FA)),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
