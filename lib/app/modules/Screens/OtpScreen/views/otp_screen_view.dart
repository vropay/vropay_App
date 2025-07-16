import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:vropay_final/Utilities%20/constants%20/Colors.dart';
import '../../../../../Components /constant_buttons.dart';
import '../../../../../Utilities /constants /KImages.dart';
import '../../onBoarding/widgets/faq_help.dart';
import '../controllers/otp_screen_controller.dart';

class OtpScreenView extends StatelessWidget {
  final OTPController _otpController = Get.find<OTPController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KConstColors.colorPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.black,
                    size: 20,),
                    onPressed: () => Get.back(),
                  ),
                ),
                Image.asset(KImages.otpScreenImage, height: 265, width: 315),

                SizedBox(height: 50),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: PinCodeTextField(
                    length: 5,
                    controller: _otpController.otpFieldController,
                    onChanged: (value) => _otpController.updateOtp(value),
                    keyboardType: TextInputType.number,
                    appContext: context,
                    textStyle: TextStyle(fontSize: 18,
                    color: Color(0xFF172B75)),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(6),
                      fieldHeight: 59,
                      fieldWidth: 49,
                      activeColor: Color(0xFFCBDAFF),
                      inactiveColor: Color(0xFFDFDFDF),
                      selectedColor: Color(0xFFCBDAFF),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // Show Email or Phone based on OTP type
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:Text("Enter 5 digit OTP sent to",
                      style: TextStyle(color: Color(0xFF454545), fontSize: 14),
                    ),
                  ),
                ),

                Obx(() => Text(
                  _otpController.isPhoneOtp.value
                      ? _otpController.userPhone.value // Displays phone if OTP is for phone
                      : _otpController.userEmail.value, // Displays email if OTP is for email
                  style: TextStyle(fontWeight: FontWeight.bold,
                  color: Color(0xFF454545)),
                )),

                // Resend OTP
                Align(
                  alignment: Alignment.centerRight,
                  child:TextButton(
                    onPressed: () => _otpController.resendOtp(),
                    child: Text(
                      "Resend OTP?",
                      style: TextStyle(
                        color: Color(0xFF4263E0),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline
                      ),
                    ),
                  ) ,
                ),

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
                // Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProgressDot(false),
                    _buildProgressDot(true),
                    _buildProgressDot(false),
                    _buildProgressDot(false)
                  ],
                ),

                SizedBox(height: 20),

                // Verify OTP Button
                Obx(() => CommonButton(
                  text: "Verify OTP",
                  onPressed: _otpController.otpCode.value.length == 5
                      ? () {
                    if (_otpController.isPhoneOtp.value) {
                      _otpController.verifyPhoneOtp();
                    } else {
                      _otpController.verifyEmailOtp();
                    }
                  }
                      : null, // Disabled if OTP is not filled
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to build progress indicator
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
