import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/payment_screen/controllers/payment_screen_controller.dart';

import '../../../../../Components/back_icon.dart';
import '../widgets/payment_dialog.dart';


class PaymentScreenView extends GetView<PaymentScreenController> {
  const PaymentScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    // Show dialog after the first frame
    Future.delayed(Duration.zero, () {
      _showPaymentDialog(context);
    });

    return Scaffold(
      body: Stack(
        children: [
          // Top content (BackIcon + Title)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  const BackIcon(),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "Get access to our programs",
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172B75),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom image
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: GestureDetector(
                onTap: () => _showPaymentDialog(context),
                child: Image.asset(
                  'assets/images/vropayLogo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => PaymentMethodDialog(controller: controller),
    );
  }
}
