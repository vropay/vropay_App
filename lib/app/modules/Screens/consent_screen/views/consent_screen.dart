import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vropay_final/Components/back_icon.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/consent_screen/controllers/consent_controller.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class ConsentScreen extends GetView<ConsentController> {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments passed from community screens
    final args = Get.arguments as Map<String, dynamic>?;
    final String subCategoryName = args?['subCategoryName'] ?? 'Community';
    final VoidCallback? onConsentAccepted = args?['onConsentAccepted'];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: BackIcon(),
                    ),
                    Image.asset(
                      KImages.catImage,
                      height: ScreenUtils.height * 0.135,
                      width: ScreenUtils.width * 0.800,
                    ),
                    SizedBox(
                      width: 0,
                    )
                  ],
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.02,
                ),
                Text(
                  "A few reminders...",
                  style: TextStyle(
                      fontSize: ScreenUtils.x(7.5),
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00B8F0)),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.015,
                ),
                Text(
                  "Your texts and comments help make VroPay A safe and inspiring place. Remember to:",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000)),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.025,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Be Kind",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF172B75)),
                  ),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.001,
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Text(
                    "Always show respect, especially when sharing feedback or different perspectives.",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF000000)),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Be Purposeful",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF172B75)),
                  ),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.001,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    "Focus on sharing new ideas and expertise that will inspire the community.",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF000000)),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Be Constructive",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF172B75)),
                  ),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.001,
                ),
                Text(
                  "Make sure u’re adding to the conversation rather than debating or spamming.",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF000000),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.03,
                ),
                Center(
                  child: Container(
                    height: ScreenUtils.height * 0.19,
                    width: ScreenUtils.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFFFFC746),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: ScreenUtils.height * 0.016,
                        ),
                        Text(
                          "You can tap & hold on any message or user \nto report !\n     But hey you can be reported too.\nRepeated reports = chat disabled.\nYou’ll still be able to scroll and read.",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(
                          height: ScreenUtils.height * 0.01,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Keep it chill. Keep it clean.",
                            style: TextStyle(
                                fontSize: ScreenUtils.x(3),
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF172B75)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.02,
                ),
                Center(
                  child: ElevatedButton(
                      onPressed: () {
                        // Call the callback if provided, otherwise navigate to message screen
                        if (onConsentAccepted != null) {
                          onConsentAccepted();
                        } else {
                          final args = Get.arguments as Map<String, dynamic>?;
                          Get.toNamed(Routes.MESSAGE_SCREEN, arguments: {
                            'interestId': args?['subCategoryId'], // ✅ ADD THIS
                            'interestName':
                                args?['subCategoryName'], // ✅ ADD THIS
                            'subCategoryId': args?['subCategoryId'],
                            'subCategoryName': args?['subCategoryName'],
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(ScreenUtils.width * 0.5,
                              ScreenUtils.height * 0.025),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Color(0xFFE70025)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "agreed",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                fontFamily: GoogleFonts.poppins().fontFamily),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        ],
                      )),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
