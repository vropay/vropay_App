import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlueEditableField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const BlueEditableField({
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: controller,
        decoration: const InputDecoration.collapsed(hintText: ''),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
