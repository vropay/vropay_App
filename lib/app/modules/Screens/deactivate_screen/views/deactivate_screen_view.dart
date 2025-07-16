import 'package:flutter/material.dart';

import 'package:get/get.dart';


import '../../../../../Components /back_icon.dart';
import '../controllers/deactivate_screen_controller.dart';

class DeactivateScreenView extends StatelessWidget {
  final controller = Get.put(DeactivateController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: BackIcon(),
              ),
              const SizedBox(height: 10),
              const Text(
                "All your profile data, preferences, and progress will be permanently deleted.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              const Text(
                "To return, you’ll need to sign up again from scratch.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "If you're just taking a break, we recommend signing out instead..\n"
                    "you can sign back in anytime and pick up where you left off.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              Image.asset("assets/images/deactivate.png", height: 120),
              const SizedBox(height: 20),
              const Text(
                "Note:\nAny active monthly subscription with auto-pay will be cancelled "
                    "after today and won’t renew.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.red),
              ),
              const SizedBox(height: 20),
              Obx(() => CheckboxListTile(
                title: const Text(
                  "I want to permanently erase my profile,\npreferences, and progress",
                  style: TextStyle(
                    color: Color(0xFF1B2B6B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: controller.confirmErase.value,
                onChanged: controller.toggleCheckbox,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              )),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: controller.onDeactivate,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      side: const BorderSide(color: Colors.pinkAccent),
                    ),
                    child: const Text(
                      "yes DEACTIVATE",
                      style: TextStyle(
                        color: Colors.pinkAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

