import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../../Utilities/constants/KImages.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/free_Trial_Toggle.dart';
import '../widgets/monthlyPayment.dart';
import '../widgets/oneTimeButton.dart';
import '../widgets/plan_toggle.dart';

class SubscriptionView extends StatelessWidget {
  final SubscriptionController controller = Get.put(SubscriptionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
            Row(
              children: [
                IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.orange),
                onPressed: () {
                  Get.back();
                },
                ),
                          const Text(
                      ' Get access to\nour programs',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w200,
                        color: Color(0xFF172B75),
                      ),
                      textAlign: TextAlign.center,
                    ),
              ],
            ),
                const SizedBox(height: 16),
                Image.asset(KImages.subscriptionImage),
                const SizedBox(height: 20),
                Obx(() => Column(
                  children: [
                    PlanToggleButton(
                      label: controller.userType.value == UserType.business
                          ? '₹1230 yearly'
                          : controller.userType.value == UserType.professional
                          ? '₹1086 yearly'
                          : '₹960 yearly',
                      onTap: () { controller.selectPlan('yearly');
                        Get.toNamed(Routes.PAYMENT_SCREEN);
                      },
                    ),
                    const SizedBox(height: 12),
                    PlanToggleButton(
                      label: controller.userType.value == UserType.business
                          ? '₹141 monthly'
                          : controller.userType.value == UserType.professional
                          ? '₹123 monthly'
                          : '₹96  monthly',
                      onTap: () {
                        controller.selectPlan('monthly');

                        Get.dialog(
                          SubscriptionDialog(
                            onBack: () => Get.back(),
                            onMonthly: () {
                              Get.toNamed(Routes.PAYMENT_SCREEN);
                            },
                            onAnnual: () {
                              Get.back();
                              Get.toNamed(Routes.PAYMENT_SCREEN);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                )),
                const SizedBox(height: 20),
                Obx(() => FreeTrialToggle(
                  isEnabled: controller.enableTrial.value,
                  onToggle: controller.toggleTrial,
                )),
                SizedBox(height: 50),
                OneTimeOfferButton(
                  onTap: () {
                    Get.toNamed(Routes.PAYMENT_SCREEN
                    );
                  }
                ),
                const SizedBox(height: 10),

                // Align widget to ensure full width
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: double.infinity,
                    child: const Divider(
                      color: Colors.grey,
                      thickness: 0.2,
                      indent: 0,
                      endIndent: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'terms & conditions\n',
                      style: TextStyle(
                        fontSize: 12, color: Color(0xFFEF2D56)
                      ),
                    ),
                    TextSpan(
                      text: 'You can cancel autopay for your monthly subscription anytime\n',
                      style: TextStyle(
                        fontSize: 12, color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: 'no hassle, no worries',
                      style: TextStyle(
                        fontSize: 12, color: Color(0xFF006DF4),
                      ),
                    ),
                  ]
                )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
