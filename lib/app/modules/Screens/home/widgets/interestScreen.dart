import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import '../../../../../Components/back_icon.dart';

import '../controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class InterestsScreen extends StatelessWidget {
  InterestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if we're coming from profile or home
    final bool isFromProfile = Get.arguments?['fromProfile'] ?? false;
    final HomeController? homeController =
        Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;
    final ProfileController? profileController =
        Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : null;

    // Initialize selected interests from user's saved topics when coming from profile
    if (isFromProfile && profileController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Ensure interests are loaded first, then sync selected interests
        if (profileController.interests.isEmpty) {
          profileController.loadInterests().then((_) {
            profileController.selectedInterests.value =
                profileController.selectedTopicsList.toList();
          });
        } else {
          profileController.selectedInterests.value =
              profileController.selectedTopicsList.toList();
        }
      });
    }

    ScreenUtils.setContext(context);
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
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: BackIcon(
                          onTap: () {
                            if (isFromProfile) {
                              Get.back();
                            } else if (homeController != null &&
                                homeController.currentStep.value > 0) {
                              homeController.currentStep.value--;
                            } else {
                              Get.back();
                            }
                          },
                        ),
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
                  final interests = isFromProfile
                      ? (profileController?.interests ?? [])
                      : (homeController?.interests ?? []);
                  final selectedInterests = isFromProfile
                      ? (profileController?.selectedInterests ?? [])
                      : (homeController?.selectedInterests ?? []);

                  return Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: interests.map((topic) {
                      final isSelected = selectedInterests.contains(topic);
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
                        onSelected: (_) async {
                          if (isFromProfile) {
                            profileController?.toggleInterest(topic);
                            // Save immediately to database
                            await profileController?.saveSelectedInterests();
                          } else {
                            homeController?.toggleInterest(topic);
                          }
                        },
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
                    onPressed: () async {
                      if (isFromProfile) {
                        if (profileController?.selectedInterests.isEmpty ??
                            true) {
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

                        // Just go back to profile (interests already saved)
                        Get.back();
                      } else {
                        if (!(homeController?.hasSelectedInterests() ??
                            false)) {
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

                        // Update selected topics and go to next step
                        homeController?.selectedTopics.value =
                            homeController?.selectedInterests.toList() ?? [];
                        homeController?.nextStep();
                      }
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
                    child: Text(
                      isFromProfile ? "Save" : "Continue",
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
