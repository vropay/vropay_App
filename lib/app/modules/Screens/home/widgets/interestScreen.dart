import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Components /back_icon.dart';
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
                const Align(
                  alignment: Alignment.centerLeft,
                  child: BackIcon(),
                ),

                const SizedBox(height: 10),

                const Center(
                  child: Image(
                    image: AssetImage('assets/images/Interest.png'),
                    height: 120,
                    width: 146,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Follow your Interests",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0066FF),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                Obx(() {
                  return Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: controller.interests.map((topic) {
                      final isSelected = controller.selectedInterests.contains(topic);
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

            const Text(
              "Choose min 1 or max all",
              style: TextStyle(
                color: Color(0xFF0066FF),
                fontSize: 15,
                fontWeight: FontWeight.w300,
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
