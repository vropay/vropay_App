import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components/back_icon.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/consent_screen/controllers/consent_controller.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class ConsentScreen extends GetView<ConsentController> {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
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
                  height: ScreenUtils.height * 0.01,
                ),
                Text(
                  "Your texts and comments help make VroPay A safe and inspiring place. Remember to:",
                  style: TextStyle(
                      fontSize: ScreenUtils.x(4),
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000)),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.02,
                ),
                Text(
                  "Be Kind",
                  style: TextStyle(
                      fontSize: ScreenUtils.x(6), color: Color(0xFF172B75)),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.001,
                ),
                Text(
                  "Always show respect, especially when sharing feedback or different perspectives.",
                  style: TextStyle(
                      fontSize: ScreenUtils.x(4),
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF000000)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.02,
                ),
                Text(
                  "Be Purposeful",
                  style: TextStyle(
                      fontSize: ScreenUtils.x(6),
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF172B75)),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.001,
                ),
                Text(
                  "Focus on sharing new ideas and expertise that will inspire the community.",
                  style: TextStyle(
                      fontSize: ScreenUtils.x(4),
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF000000)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.02,
                ),
                Text(
                  "Be Constructive",
                  style: TextStyle(
                      fontSize: ScreenUtils.x(6),
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF172B75)),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.001,
                ),
                Text(
                  "Make sure u’re adding to the conversation rather than debating or spamming.",
                  style: TextStyle(
                    fontSize: ScreenUtils.x(4),
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
                    height: ScreenUtils.height * 0.165,
                    width: ScreenUtils.width * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xFFFFC746),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: ScreenUtils.height * 0.01,
                        ),
                        Text(
                          "You can tap & hold on any message or user \nto report !\n     But hey you can be reported too.\nRepeated reports = chat disabled.\nYou’ll still be able to scroll and read.",
                          style: TextStyle(
                            fontSize: ScreenUtils.x(3),
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                            height: 20 / ScreenUtils.x(3),
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
                                color: Color(0xFF000000)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: ScreenUtils.height * 0.03,
                ),
                Center(
                  child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(Routes.MESSAGE_SCREEN);
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: Size(ScreenUtils.width * 0.4,
                              ScreenUtils.height * 0.03),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor: Color(0xFFE70025)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            "agreed",
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 24,
                          )
                        ],
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
