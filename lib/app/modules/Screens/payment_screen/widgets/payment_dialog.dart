import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

import '../../../../../Components /back_icon.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/payment_screen_controller.dart';

class PaymentMethodDialog extends StatelessWidget {
  final PaymentScreenController controller;

  const PaymentMethodDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF7F7F7),
      child: SizedBox(
        width: double.infinity,
        height: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: BackIcon(),
                onPressed: () => Get.offAllNamed(Routes.SUBSCRIPTION),
              ),
              const Text(
                " Select Payment Method",
                style: TextStyle(color: Color(0xFF333333), fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildMethodTile("Debit / Credit Card", PaymentMethod.card, controller),
                    Obx(() {
                      return controller.selectedMethod.value == PaymentMethod.card
                          ? _buildCardForm(controller)
                          : const SizedBox.shrink();
                    }),
                    const Divider(),
                    _buildMethodTile("UPI", PaymentMethod.upi, controller),
                    Obx(() {
                      return controller.selectedMethod.value == PaymentMethod.upi
                          ? _buildUpiForm(controller)
                          : const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodTile(String title, PaymentMethod method, PaymentScreenController controller) {
    IconData iconData;
    switch (method) {
      case PaymentMethod.card:
        iconData = Icons.credit_card;
        break;
      case PaymentMethod.upi:
        iconData = Icons.currency_rupee;
        break;
    }

    return Obx(() {
      final selected = controller.selectedMethod.value == method;
      return ListTile(
        onTap: () => controller.switchMethod(method),
        leading: Icon(iconData, color: const Color(0xFF172B75)),
        title: Text(
          title,
          style: TextStyle(
            color: const Color(0xFF172B75),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: Icon(
          selected ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: const Color(0xFFFFA000),
        ),
      );
    });
  }

  Widget _buildCardForm(PaymentScreenController controller) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          _textField(controller.cardNumber, "Card Number", hint: "xxxx-xxxx-xxxx-xxxx", maxLength: 16),
          Row(
            children: [
              Expanded(
                child: _textField(
                  controller.cvv,
                  "CVV",
                  hint: "000",
                  maxLength: 3,
                  errorText: controller.showCardError.value && controller.cvv.text.length != 3
                      ? "Enter valid CVV"
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _textField(controller.expiry, "Valid Thru", hint: "MM/YYYY"),
              ),
            ],
          ),
          _textField(controller.cardHolder, "Full Name", hint: "Name"),
          const SizedBox(height: 12),
          Obx(() => ElevatedButton(
            onPressed: controller.isCardFormFilled.value ? controller.validateCard : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.isCardFormFilled.value
                  ? const Color(0xFFEF2D56)
                  : Colors.grey,
              minimumSize: const Size.fromHeight(45),
            ),
            child: const Text("Send OTP", style: TextStyle(color: Colors.white)),
          )),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(value: false, onChanged: (_) {}),
              const Text("Save details for future", style: TextStyle(color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpiForm(PaymentScreenController controller) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Choose App", style: TextStyle(color: Color(0xFF373737))),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: controller.upiApps.map((app) => _upiAppButton(app, controller)).toList(),
          ),
          const SizedBox(height: 12),
          const Text("Or", style: TextStyle(color: Colors.black)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _textField(
                  controller.upiId,
                  "Enter UPI ID",
                  hint: "example@upi",
                  errorText: controller.showUpiError.value && !controller.upiId.text.contains("@")
                      ? "Enter valid UPI ID"
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: controller.isUpiFormFilled
                    ? () => controller.validateUpi()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isUpiFormFilled ? const Color(0xFFEF2D56) : Colors.grey.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text("Verify", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(value: false, onChanged: (_) {}),
              const Text("Save details for future", style: TextStyle(color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _upiAppButton(Map<String, String> app, PaymentScreenController controller) {
    return GestureDetector(
      onTap: () => controller.selectUpiApp(app['name']!),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              app['image']!,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 6),
          Text(app['name']!, style: const TextStyle(color: Colors.black, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _textField(
      TextEditingController ctrl,
      String label, {
        String? hint,
        String? errorText,
        int? maxLength,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF172B75))),
          const SizedBox(height: 4),
          TextField(
            controller: ctrl,
            maxLength: maxLength,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              errorText: errorText,
              counterText: '',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
