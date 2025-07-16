import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components%20/constant_buttons.dart';
import '../../../../../Utilities /constants /Colors.dart';
import '../../../../../Utilities /constants /KImages.dart';
import '../../OtpScreen/views/otp_screen_view.dart';
import '../../onBoarding/widgets/faq_help.dart';
import '../controllers/phone_verification_controller.dart';

class PhoneVerificationView extends GetView<PhoneVerificationController> {
  PhoneVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KConstColors.colorPrimary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: KConstColors.colorSecondary),
                  onPressed: () => Get.back(),
                ),
              ),
              Image.asset(KImages.authImage, height: 276.5, width: 276.5),
              SizedBox(height: 30),
              Text(
                "Phone Number",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF454545)),
              ),
              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 343,
                  height: 56,
                  child: TextField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        child: Image.asset(KImages.phoneIconImage, width: 24, height: 24),
                      ),
                      hintText: "00000 00000",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      counterText: "",
                    ),
                    onChanged: (value) {
                      controller.isValid.value =
                          value.length == 10 && RegExp(r'^[0-9]+$').hasMatch(value);
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text("Enter your mobile number to send OTP",
                  style: TextStyle(fontSize: 12, color: Color(0xFFC1C0C0))),
              SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text.rich(
                  TextSpan(
                    text: "By continuing, you agree to VRopay’s ",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    children: [
                      TextSpan(
                        text: "Terms of Service",
                        style: const TextStyle(
                            color: Color(0xFF45548F)),
                      ),
                      const TextSpan(text: " and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: const TextStyle(
                            color: Color(0xFF45548F)),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10,),
              FaqHelpText(),
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProgressDot(false),
                  _buildProgressDot(false),
                  _buildProgressDot(true),
                  _buildProgressDot(false),
                ],
              ),
              SizedBox(height: 20),
              Obx(() => CommonButton(
                text: "Send OTP",
                onPressed: controller.isValid.value
                    ? () {
                  controller.sendOtpToPhone();
                  Get.to(() => OtpScreenView(),);
                }
                    : null,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDot(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: isActive ? 9 : 30,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF172B75) : Color(0xFFD0D0D0),
        borderRadius: BorderRadius.circular(19),
      ),
    );
  }
}
