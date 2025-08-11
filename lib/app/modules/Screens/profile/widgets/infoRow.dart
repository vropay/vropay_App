import 'package:flutter/cupertino.dart';

class InfoFieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEditMode;
  final Widget editChild;
  final String? helper;

  const InfoFieldRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isEditMode,
    required this.editChild,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF83A5FA)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            isEditMode
                ? SizedBox(width: 160, child: editChild)
                : Text('Selected', textAlign: TextAlign.right),
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
}
