import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';

import '../../../../../Utilities/constants/KImages.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/free_Trial_Toggle.dart';
import '../widgets/monthlyPayment.dart';
import '../widgets/oneTimeButton.dart';
import '../widgets/plan_toggle.dart';

class SubscriptionView extends StatelessWidget {
  final SubscriptionController controller = Get.put(SubscriptionController());

  SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtils.setContext(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: ScreenUtils.height * 0.02),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_outlined,
                        color: Colors.orange),
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
              SizedBox(height: ScreenUtils.height * 0.03),
              Image.asset(KImages.subscriptionImage),
              SizedBox(height: ScreenUtils.height * 0.02),
              Obx(() => Column(
                    children: [
                      PlanToggleButton(
                        label: controller.userType.value == UserType.business
                            ? '₹1230 yearly'
                            : controller.userType.value == UserType.professional
                                ? '₹1086 yearly'
                                : '₹960 yearly',
                        onTap: () {
                          controller.selectPlan('yearly');
                          Get.toNamed(Routes.PAYMENT_SCREEN);
                        },
                      ),
                      SizedBox(height: ScreenUtils.height * 0.01),
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
              SizedBox(height: ScreenUtils.height * 0.02),
              Obx(() => FreeTrialToggle(
                    isEnabled: controller.enableTrial.value,
                    onToggle: controller.toggleTrial,
                  )),
              SizedBox(height: ScreenUtils.height * 0.05),
              OneTimeOfferButton(onTap: () {
                Get.toNamed(Routes.PAYMENT_SCREEN);
              }),
              SizedBox(height: ScreenUtils.height * 0.01),

              // Align widget to ensure full width
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: double.infinity,
                  child: Divider(
                    color: Colors.grey,
                    thickness: 0.2,
                    indent: 0,
                    endIndent: 0,
                  ),
                ),
              ),
              SizedBox(height: ScreenUtils.height * 0.01),

              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(children: [
                    TextSpan(
                      text: 'terms & conditions\n',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEF2D56),
                          fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text:
                          'You can cancel autopay for your monthly subscription anytime\n',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: 'no hassle, no worries',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF006DF4),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ])),
              SizedBox(
                height: ScreenUtils.height * 0.01,
              )
            ],
          ),
        ),
      ),
    );
  }
}
