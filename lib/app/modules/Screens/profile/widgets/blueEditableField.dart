import 'package:flutter/material.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';

class BlueEditableField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const BlueEditableField({
    super.key,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtils.height * 0.05,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: controller,
        decoration: const InputDecoration.collapsed(hintText: ''),
        style: TextStyle(
            fontSize: 16,
            color: Color(0xFF616161),
            fontWeight: FontWeight.w400),
        textAlign: TextAlign.center,
      ),
    );
  }
}
