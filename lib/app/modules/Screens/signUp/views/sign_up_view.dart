import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';

import '../../../../../Components/constant_buttons.dart';
import '../../../../../Utilities/constants/Colors.dart';
import '../../onBoarding/widgets/faq_help.dart';
import '../controllers/sign_up_controller.dart';
import '../widgets/socialButtons.dart';

class SignUpView extends StatelessWidget {
  final SignUpController _controller = Get.put(SignUpController());

  SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtils.setContext(context);
    return Scaffold(
      backgroundColor: KConstColors.colorPrimary,
      appBar: AppBar(
        backgroundColor: KConstColors.colorPrimary,
        iconTheme: IconThemeData(
          color: KConstColors.colorSecondary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                KImages.authImage,
                height: 276.5,
                width: 276.5,
              ),
              Padding(padding: EdgeInsets.only(bottom: 30)),

              // Social Login Buttons
              Obx(
                () => SocialButton(
                  text: "Continue with Google",
                  iconPath: KImages.googleIcon,
                  onPressed: _controller.isLoading.value
                      ? null
                      : () {
                          _controller.signUpWithGoogle();
                        },
                ),
              ),
              SizedBox(height: ScreenUtils.height * 0.021),

              Obx(() => SocialButton(
                  text: "Continue with Apple",
                  iconPath: KImages.appleIcon,
                  onPressed: _controller.isLoading.value
                      ? null
                      : () {
                          // Apple sign in implementation
                          _controller.signUpWithApple();
                        })),

              const SizedBox(height: 10),
              const Text("or",
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 10),

              // Email Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 343,
                      height: 56,
                      child: TextField(
                        controller: _controller.emailController,
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          _controller
                              .validateInput(); // <- This updates isEmailEmpty
                        }, // Centers the input text
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(30)), // Rounded border
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide:
                                BorderSide(color: Colors.black, width: 1),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                          labelText: "", // Hide the default label
                        ),
                      ),
                    ),
                    Obx(() {
                      return _controller.isEmailEmpty.value
                          ? Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.email_outlined,
                                      color: Colors.grey, size: 24),
                                  SizedBox(width: 10),
                                  Text(
                                    "Email ID",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(); // Hide icon and text when typing
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Error message
              Obx(() {
                if (_controller.errorMessage.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _controller.errorMessage.value,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                return SizedBox.shrink();
              }),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text.rich(
                  TextSpan(
                    text: "By continuing, you agree to VRopay’s ",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    children: [
                      TextSpan(
                        text: "Terms of Service",
                        style: const TextStyle(color: Color(0xFF45548F)),
                      ),
                      const TextSpan(text: " and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: const TextStyle(color: Color(0xFF45548F)),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              FaqHelpText(),
              SizedBox(
                height: 30,
              ),
              // Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProgressDot(false),
                  _buildProgressDot(true),
                  _buildProgressDot(false),
                  _buildProgressDot(false)
                ],
              ),
              const SizedBox(height: 15),

              // Send OTP Button
              Obx(() => CommonButton(
                    text:
                        _controller.isLoading.value ? "Sending..." : "Send OTP",
                    onPressed: _controller.isValid.value &&
                            !_controller.isLoading.value
                        ? () {
                            _controller.signUpWithEmail();
                          }
                        : null,
                  )),

              const SizedBox(height: 20),

              // Sign In Navigation
              GestureDetector(
                onTap: () {
                  Get.toNamed('/signin'); // Navigate to Sign In page
                },
                child: RichText(
                  text: TextSpan(
                    text: "have an account? ",
                    style: TextStyle(
                        fontSize: 14, color: KConstColors.colorSecondary),
                    children: [
                      TextSpan(
                        text: "SIGN IN",
                        style: const TextStyle(
                            color: Color(0xFF172B75),
                            fontSize: 16,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
