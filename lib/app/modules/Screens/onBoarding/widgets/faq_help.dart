import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class FaqHelpText extends StatelessWidget {
  const FaqHelpText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: 'Need help? ',
        style: const TextStyle(
            color: Color(0xFF777777),
            fontSize: 9.4,
            fontWeight: FontWeight.w400),
        children: [
          TextSpan(
            text: '[FAQs]',
            style: const TextStyle(
                color: Color(0xFF45548F),
                fontWeight: FontWeight.w400,
                fontSize: 9.4),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // You can replace this with your own custom dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('FAQs'),
                    content: const Text('Instructions will be added here.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
          ),
        ],
      ),
    );
  }
}
