import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:vropay_final/Components/constant_buttons.dart';
import 'package:vropay_final/Utilities/constants/Colors.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/onBoarding/controllers/on_boarding_controller.dart';
import 'package:vropay_final/app/modules/Screens/onBoarding/widgets/faq_help.dart';
import 'package:vropay_final/app/modules/Screens/signUp/widgets/socialButtons.dart';

class OnBoardingView extends GetView<OnBoardingController> {
  const OnBoardingView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtils.setContext(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                // Disable user swiping - only allow programmatic navigation
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildOnboardingPage(
                    image: KImages.onBoardingScreen,
                    title:
                        "Smart tools\nReal-time insights\n&\nLimitless possibilities",
                    subtitle: "—ready to level up your skills?",
                    showFaq: true,
                  ),
                  Obx(() => controller.currentPage.value == 1
                      ? (controller.showPhoneVerification.value
                          ? _buildPhoneVerification()
                          : _buildSignUpPage())
                      : Center(
                          child: CircularProgressIndicator(),
                        )),
                  _buildOtpScreen(),
                ],
              ),
            ),
            // Action Button
            Obx(
              () => controller.currentPage.value == 0
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: CommonButton(
                              onPressed: controller.goToNextPage,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.arrow_forward_ios,
                                      color: KConstColors.colorPrimary,
                                      size: 20),
                                  Transform.translate(
                                    offset: const Offset(-6, 0),
                                    child: const Icon(Icons.arrow_forward_ios,
                                        color: KConstColors.colorPrimary,
                                        size: 20),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(-12, 0),
                                    child: const Icon(Icons.arrow_forward_ios,
                                        color: KConstColors.colorPrimary,
                                        size: 20),
                                  ),
                                  SizedBox(width: ScreenUtils.width * 0.08),
                                  GestureDetector(
                                    child: const Text(
                                      "Let's Sign Up",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: KConstColors.colorPrimary,
                                      ),
                                    ),
                                    onTap: () {
                                      // Call API instead of just navigating
                                      controller.goToNextPage();
                                    },
                                  ),
                                ],
                              )),
                        ),
                        const SizedBox(height: 20),

                        // Sign In Link
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: "have an account? ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: KConstColors.onBoardingSubTitle,
                                ),
                              ),
                              TextSpan(
                                text: "\nSIGN IN",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: KConstColors.onBoardingSubHeading,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    controller.isSignInFlow.value = true;
                                    print(
                                        "Is sign in flow: ${controller.isSignInFlow.value}");
                                    controller.goToSignIn();
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String image,
    required String title,
    required String subtitle,
    required bool showFaq,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Image.asset(
            image,
            fit: BoxFit.contain,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: KConstColors.onBoardingText,
                  ),
                  children: title.split('\n').map((line) {
                    if (line == '&') {
                      return TextSpan(
                        text: "$line\n",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF0066FF),
                        ),
                      );
                    }
                    return TextSpan(
                      text: "$line\n",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 18,
                  color: KConstColors.onBoardingSubHeading,
                ),
              ),
              if (showFaq) ...[
                const SizedBox(height: 20),
                FaqHelpText(),
              ],

              // Add page indicator for pages
              if (showFaq) ...[
                SizedBox(height: ScreenUtils.height * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProgressDot(true),
                    _buildProgressDot(false),
                    _buildProgressDot(false),
                    _buildProgressDot(false),
                  ],
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpPage() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Builder(
            builder: (context) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ),
                ),
                Image.asset(
                  KImages.authImage,
                  height: 276.5,
                  width: 276.5,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.024,
                ),

                // Social Login Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Obx(
                    () => controller.isLoading.value
                        ? Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xFf172B75)),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFf172B75),
                              ),
                            ),
                          )
                        : SocialButton(
                            text: "Continue with Google",
                            textColor: Color(0xFf172B75),
                            borderColor: Color(0xFf172B75),
                            iconPath: KImages.googleIcon,
                            onPressed: () {
                              // Call Google Auth API
                              controller.signUpWithGoogle();
                            },
                          ),
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.021,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: SocialButton(
                    text: "Continue with Apple",
                    iconPath: KImages.appleIcon,
                    textColor: Colors.grey[900]!,
                    borderColor: Colors.grey[300]!,
                    onPressed: () {
                      controller.signUpWithApple();
                    },
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 59),
                  child: Row(
                    children: [
                      Expanded(
                          child: Divider(
                        endIndent: 8,
                        color: Color(0xFFD9D9D9),
                      )),
                      Text("or",
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF9A9A9A),
                              fontFamily: GoogleFonts.poppins().fontFamily)),
                      Expanded(
                          child: Divider(
                        indent: 8,
                        color: Color(0xFFD9D9D9),
                      ))
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),

                // Email Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 343,
                        height: 56,
                        child: TextField(
                          controller: controller.emailController,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF172B75)),
                          onChanged: (value) {
                            if (!controller.isDisposed) {
                              controller.validateInput();
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "Email ID",
                            hintStyle: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF9E9E9E),
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontWeight: FontWeight.w400),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Color(0xFF9E9E9E),
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(30)), // Rounded border
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              borderSide: BorderSide(
                                  color: Colors.grey[300]!, width: 1),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 18),
                          ),
                        ),
                      ),
                      // Obx(() {
                      //   return controller.isEmailEmpty.value
                      //       ? Center(
                      //           child: Row(
                      //             mainAxisAlignment: MainAxisAlignment.center,
                      //             children: [
                      //               Icon(Icons.email_outlined,
                      //                   color: Color(0xFF9E9E9E), size: 20),
                      //               SizedBox(width: 10),
                      //               Text(
                      //                 "Email ID",
                      //                 style: TextStyle(
                      //                     fontSize: 16,
                      //                     color: Color(0xFF9E9E9E),
                      //                     fontFamily:
                      //                         GoogleFonts.poppins().fontFamily,
                      //                     fontWeight: FontWeight.w400),
                      //               ),
                      //             ],
                      //           ),
                      //         )
                      //       : SizedBox
                      //           .shrink(); // Hide icon and text when typing
                      // }),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      text: "By continuing, you agree to VRopay’s\n",
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF777777)),
                      children: [
                        TextSpan(
                          text: "Terms of Service",
                          style: const TextStyle(
                              color: Color(0xFF45548F),
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              decoration: TextDecoration.underline),
                        ),
                        const TextSpan(
                          text: " and ",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF777777)),
                        ),
                        TextSpan(
                          text: "Privacy Policy",
                          style: const TextStyle(
                              color: Color(0xFF45548F),
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.015,
                ),
                FaqHelpText(),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.017,
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.015,
                ),

                // let's sign up button
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Obx(
                      () => controller.isLoading.value
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : CommonButton(
                              text: "Let's Sign up",
                              onPressed: () {
                                controller.signUpWithEmail();
                              }),
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),

                // Sign In Navigation
                GestureDetector(
                  onTap: () {
                    controller.isSignInFlow.value = true;
                    print("Is sign in flow: ${controller.isSignInFlow.value}");
                    controller.showPhoneVerification.value = true;
                  },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "have an account?\n",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: KConstColors.onBoardingSubTitle,
                      ),
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
              ],
            ),
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

  Widget _buildPhoneVerification() {
    return Scaffold(
      backgroundColor: KConstColors.colorPrimary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      color: KConstColors.colorSecondary),
                  onPressed: () => controller.goBackToSignUp(),
                ),
              ),
            ),
            Image.asset(KImages.authImage, height: 276.5, width: 276.5),
            SizedBox(height: ScreenUtils.height * 0.056),
            Text(
              "Phone Number",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF454545),
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
            ),
            SizedBox(height: ScreenUtils.height * 0.02),
            Center(
              child: SizedBox(
                width: ScreenUtils.width * 0.8,
                height: ScreenUtils.height * 0.06,
                child: TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 70, top: 14, bottom: 14),
                      child: Image.asset(KImages.phoneIconImage,
                          width: 28, height: 28),
                    ),
                    hintText: "00000 00000",
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9E9E9E),
                      fontFamily: GoogleFonts.poppins().fontFamily,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    counterText: "",
                  ),
                  onChanged: (value) {
                    if (!controller.isDisposed) {
                      controller.isValidPhone.value = value.length == 10 &&
                          RegExp(r'^[0-9]+$').hasMatch(value);
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: ScreenUtils.height * 0.01),
            Text("Enter your mobile number to send OTP",
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFC1C0C0),
                    fontWeight: FontWeight.w400)),
            SizedBox(height: ScreenUtils.height * 0.086),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text.rich(
                TextSpan(
                  text: "By continuing, you agree to VRopay’s\n",
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF777777),
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontWeight: FontWeight.w300),
                  children: [
                    TextSpan(
                      text: "Terms of Service",
                      style: TextStyle(
                          color: Color(0xFF45548F),
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          decoration: TextDecoration.underline),
                    ),
                    const TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy Policy",
                      style: TextStyle(
                          color: Color(0xFF45548F),
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          decoration: TextDecoration.underline),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: ScreenUtils.height * 0.015,
            ),
            FaqHelpText(),
            SizedBox(
              height: ScreenUtils.height * 0.017,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProgressDot(false),
                _buildProgressDot(true),
                _buildProgressDot(false),
                _buildProgressDot(false),
              ],
            ),
            SizedBox(height: ScreenUtils.height * 0.024),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Obx(
                () => controller.isLoading.value
                    ? Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      )
                    : CommonButton(
                        text: "Send OTP",
                        onPressed: () {
                          controller.isPhoneOtp.value = true;
                          print(
                              "Is sign in flow: ${controller.isSignInFlow.value}");

                          if (controller.isSignInFlow.value) {
                            controller
                                .sendSigninPhoneOtp(); // use sign in verification
                          } else {
                            // Since this screen appears after email verification, it's always signup flow
                            controller.sendSignupPhoneOtp();
                          }
                        }),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOtpScreen() {
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
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                      size: 20,
                    ),
                    onPressed: () {
                      // Go back to the sign-up page
                      controller.currentPage.value = 1;
                      controller.pageController.animateToPage(1,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    },
                  ),
                ),
                Image.asset(KImages.otpScreenImage, height: 265, width: 315),

                SizedBox(height: ScreenUtils.height * 0.05),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: PinCodeTextField(
                    length: 5,
                    onChanged: (value) {
                      try {
                        controller.updateOtp(value);
                      } catch (e) {
                        // Ignore disposal errors
                      }
                    },
                    appContext: Get.context!,
                    onCompleted: (value) {
                      try {
                        controller.updateOtp(value);
                      } catch (e) {
                        // Ignore disposal errors
                      }
                    },
                    textStyle:
                        TextStyle(fontSize: 18, color: Color(0xFF172B75)),
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10),
                      fieldHeight: 59,
                      fieldWidth: 49,
                      activeColor: Color(0xFFCBDAFF),
                      inactiveColor: Color(0xFFDFDFDF),
                      selectedColor: Color(0xFFCBDAFF),
                    ),
                  ),
                ),

                // Show Email or Phone based on OTP type
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Enter 5 digit OTP sent to",
                          style: TextStyle(
                              color: Color(0xFF454545),
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              fontFamily: GoogleFonts.poppins().fontFamily),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Obx(() => Text(
                            controller.isPhoneOtp.value
                                ? controller.userPhone
                                    .value // Displays phone if OTP is for phone
                                : controller.userEmail
                                    .value, // Displays email if OTP is for email
                            style: TextStyle(
                              color: Color(0xFF454545),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtils.height * 0.01),
                // Resend OTP
                Align(
                  alignment: Alignment.centerRight,
                  child: Obx(() {
                    if (controller.canResendOtp.value) {
                      return TextButton(
                        onPressed: () => controller.resendOtp(),
                        child: Text(
                          "Resend OTP?",
                          style: TextStyle(
                              color: Color(0xFF4263E0),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              fontFamily: GoogleFonts.poppins().fontFamily),
                        ),
                      );
                    } else {
                      return TextButton(
                          onPressed: null,
                          child: Text(
                              "Resend OTP in ${controller.getFormatterTimer()}",
                              style: TextStyle(
                                  color: Color(0xFF4263E0),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  fontFamily:
                                      GoogleFonts.poppins().fontFamily)));
                    }
                  }),
                ),

                SizedBox(height: ScreenUtils.height * 0.053),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text.rich(
                    TextSpan(
                      text: "By continuing, you agree to VRopay's\n",
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF777777),
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontWeight: FontWeight.w300),
                      children: [
                        TextSpan(
                          text: "Terms of Service",
                          style: TextStyle(
                              color: const Color(0xFF45548F),
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              decoration: TextDecoration.underline),
                        ),
                        const TextSpan(text: " and "),
                        TextSpan(
                          text: "Privacy Policy",
                          style: TextStyle(
                              color: Color(0xFF45548F),
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.01,
                ),
                FaqHelpText(),
                SizedBox(
                  height: ScreenUtils.height * 0.03,
                ),
                // Progress Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProgressDot(false),
                    _buildProgressDot(false),
                    _buildProgressDot(true),
                    _buildProgressDot(false),
                  ],
                ),
                SizedBox(height: ScreenUtils.height * 0.03),

                // Verify Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: CommonButton(
                      text: "Verify OTP",
                      onPressed: () {
                        if (controller.isSignInFlow.value) {
                          controller
                              .verifySignInOtp(); // use sign in verification
                        } else {
                          controller.verifyOtp();
                        }
                      }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
