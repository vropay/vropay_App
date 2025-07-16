import 'package:flutter/material.dart';

class FreeTrialToggle extends StatelessWidget {
  final bool isEnabled;
  final Function(bool) onToggle;

  const FreeTrialToggle({required this.isEnabled, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 311,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color:  Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFF172B75)
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'wanna try for free?',
                style: TextStyle(
                  color: Color(0xFF172B75),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'For one month only',
                style: TextStyle(
                  color: Color(0xFF172B75),
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => onToggle(!isEnabled),
            child: Container(
              width: 60,
              height: 34,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isEnabled? Colors.grey: Color(0xFF172B75),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Align(
                alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
