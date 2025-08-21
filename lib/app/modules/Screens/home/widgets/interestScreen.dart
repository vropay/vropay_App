import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import '../../../../../Components/back_icon.dart';
import 'communityAccess.dart';
import 'difficultyScreen.dart';
import 'notificationPopUp.dart';
import '../controllers/home_controller.dart';

class InterestsScreen extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: ScreenUtils.height * 0.02),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: const Align(
                        alignment: Alignment.topCenter,
                        child: BackIcon(),
                      ),
                    ),
                    SizedBox(width: ScreenUtils.width * 0.01),
                    Center(
                      child: Image(
                        image: const AssetImage('assets/images/Interest.png'),
                        height: ScreenUtils.height * 0.155,
                        width: ScreenUtils.width * 0.74,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Follow your Interests",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF0066FF),
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ScreenUtils.height * 0.02),
                Obx(() {
                  return Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: controller.interests.map((topic) {
                      final isSelected =
                          controller.selectedInterests.contains(topic);
                      return ChoiceChip(
                        showCheckmark: false,
                        label: Text(topic),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Color(0xFF172B75),
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Color(0xFF172B75),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Color(0xFF172B75)),
                          borderRadius: BorderRadius.circular(35),
                        ),
                        selected: isSelected,
                        onSelected: (_) => controller.toggleInterest(topic),
                      );
                    }).toList(),
                  );
                }),
                Text(
                  "Choose min 1 or max all",
                  style: TextStyle(
                    color: const Color(0xFF0066FF),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!controller.hasSelectedInterests()) {
                        Get.snackbar(
                          "Hold on!",
                          "Please select at least one interest.",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(15),
                        );
                        return;
                      }

                      Get.dialog(
                        DifficultyLevelScreen(
                          onNext: () {
                            Get.back();
                            Get.dialog(
                              CommunityAccessScreen(
                                onNext: () {
                                  Get.back();
                                  Get.dialog(
                                    NotificationScreen(
                                      onFinish: () {
                                        Get.back();
                                        Get.offAllNamed('/subscription');
                                      },
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        barrierDismissible: false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: const BorderSide(
                          color: Color(0xFFEF2D56),
                          width: 0.2,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        color: Color(0xFFEF2D56),
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
