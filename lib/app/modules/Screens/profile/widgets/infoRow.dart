import 'package:flutter/material.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';

class InfoFieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEditMode;
  final String? helper;
  final String? hint;

  const InfoFieldRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isEditMode,
    this.helper,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF83A5FA)),
            SizedBox(width: ScreenUtils.width * 0.04),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF172B75),
              ),
            ),
            const Spacer(),
            isEditMode
                ? SizedBox(
                    width: 160,
                    child: _buildEditableField(),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF616161),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            SizedBox(width: ScreenUtils.width * 0.00),
          ],
        ),
        if (isEditMode && helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 40),
            child: Text(
              helper!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4D84F7),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEditableField() {
    return Container(
      height: ScreenUtils.height * 0.05,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: TextFormField(
        decoration: InputDecoration.collapsed(
          hintText: hint ?? '',
        ),
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF616161),
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
