import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/profile/controllers/profile_controller.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';

// Category Preference Widget
class CategoryPreferenceWidget extends StatelessWidget {
  final RxString selectedValue;
  final List<String> options;

  const CategoryPreferenceWidget({
    super.key,
    required this.selectedValue,
    required this.options,
  });

  void _showCustomDropdown(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
            button.localToGlobal(Offset.zero),
            button.localToGlobal(button.size.bottomRight(Offset.zero),
                ancestor: overlay)),
        Offset.zero & overlay.size);

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: GestureDetector(
                  onTap: () {
                    overlayEntry?.remove();
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 400,
              right: 10,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: ScreenUtils.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((String choice) {
                      final bool isSelected = selectedValue.value == choice;
                      return InkWell(
                        onTap: () async {
                          selectedValue.value = choice;
                          final controller = Get.find<ProfileController>();
                          controller.updateProfession(choice);

                          // Save immediately to backend with null safety
                          try {
                            final authService = Get.find<AuthService>();
                            await authService.updateUserProfile(
                              firstName:
                                  controller.firstNameController.text.isNotEmpty
                                      ? controller.firstNameController.text
                                      : controller.user.value?.firstName ?? '',
                              lastName:
                                  controller.lastNameController.text.isNotEmpty
                                      ? controller.lastNameController.text
                                      : controller.user.value?.lastName ?? '',
                              mobile:
                                  controller.mobileController.text.isNotEmpty
                                      ? controller.mobileController.text
                                      : controller.user.value?.mobile ?? '',
                              profession: choice,
                              gender: controller.selectedGender.value,
                            );
                          } catch (e) {
                            print('Error updating profession: $e');
                          }

                          overlayEntry?.remove();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEAF1FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                choice,
                                style: const TextStyle(
                                  color: Color(0xFF616161),
                                  fontSize: 14,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Colors.redAccent, size: 18),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/category.png',
                    width: 21,
                    height: 21,
                    color: Color(0xFF4D84F7),
                  ),
                  SizedBox(width: ScreenUtils.width * 0.024),
                  Text(
                    'category',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF172B75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: GestureDetector(
                  onTap: () => _showCustomDropdown(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedValue.value.isEmpty ? ' ' : selectedValue.value,
                        style: const TextStyle(
                            color: Color(0xFF616161),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(width: ScreenUtils.width * 0.05),
                      Icon(Icons.keyboard_arrow_down_sharp,
                          color: Color(0xFF4D84F7)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// Interests Preference Widget
class InterestsPreferenceWidget extends StatelessWidget {
  final ProfileController controller;

  const InterestsPreferenceWidget({
    super.key,
    required this.controller,
  });

  void _showInterestsDialog(BuildContext context) {
    // Load interests and set previously selected ones
    controller.showInterestsSelection();

    // Ensure selected interests are populated from user data
    final user = controller.user.value;
    if (user?.selectedTopics != null) {
      controller.selectedInterests.value = user!.selectedTopics!.toList();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Select Interests',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF172B75),
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Obx(() => ListView.builder(
                        itemCount: controller.interests.length,
                        itemBuilder: (context, index) {
                          final interest = controller.interests[index];
                          final isSelected =
                              controller.selectedInterests.contains(interest);

                          return CheckboxListTile(
                            title: Text(interest),
                            value: isSelected,
                            onChanged: (bool? value) {
                              controller.toggleInterest(interest);
                            },
                            activeColor: Color(0xFF4D84F7),
                          );
                        },
                      )),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await controller.saveSelectedInterests();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4D84F7),
                      ),
                      child:
                          Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.interests,
                    size: 18,
                    color: Color(0xFF4D84F7),
                  ),
                  SizedBox(width: ScreenUtils.width * 0.028),
                  Text(
                    'Interests',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF172B75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(width: ScreenUtils.width * 0.18),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showInterestsDialog(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          controller.selectedTopics.value.isEmpty
                              ? 'Select interests'
                              : controller.selectedTopics.value,
                          style: const TextStyle(
                              color: Color(0xFF616161),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Icon(Icons.keyboard_arrow_down_sharp,
                          color: Color(0xFF4D84F7)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// Topics Preference Widget
class TopicsPreferenceWidget extends StatelessWidget {
  final RxString selectedValue;
  final List<String> options;

  const TopicsPreferenceWidget({
    super.key,
    required this.selectedValue,
    required this.options,
  });

  void _showCustomDropdown(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
            button.localToGlobal(Offset.zero),
            button.localToGlobal(button.size.bottomRight(Offset.zero),
                ancestor: overlay)),
        Offset.zero & overlay.size);

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: GestureDetector(
                  onTap: () {
                    overlayEntry?.remove();
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 400,
              right: 10,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: ScreenUtils.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((String choice) {
                      final bool isSelected = selectedValue.value == choice;
                      return InkWell(
                        onTap: () {
                          selectedValue.value = choice;
                          overlayEntry?.remove();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEAF1FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                choice,
                                style: const TextStyle(
                                  color: Color(0xFF616161),
                                  fontSize: 14,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Colors.redAccent, size: 18),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/topics.png',
                    width: 16,
                    height: 16,
                    color: Color(0xFF4D84F7),
                  ),
                  SizedBox(width: ScreenUtils.width * 0.028),
                  Text(
                    'Topics',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF172B75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(width: ScreenUtils.width * 0.2),
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: GestureDetector(
                  onTap: () => _showCustomDropdown(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedValue.value.isEmpty ? ' ' : selectedValue.value,
                        style: const TextStyle(
                            color: Color(0xFF616161),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(width: ScreenUtils.width * 0.1),
                      Icon(Icons.keyboard_arrow_down_sharp,
                          color: Color(0xFF4D84F7)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// Difficulty Preference Widget
class DifficultyPreferenceWidget extends StatelessWidget {
  final RxString selectedValue;
  final List<String> options;

  const DifficultyPreferenceWidget({
    super.key,
    required this.selectedValue,
    required this.options,
  });

  void _showCustomDropdown(BuildContext context) {
    ScreenUtils.setContext(context);
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
            button.localToGlobal(Offset.zero),
            button.localToGlobal(button.size.bottomRight(Offset.zero),
                ancestor: overlay)),
        Offset.zero & overlay.size);

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: GestureDetector(
                  onTap: () {
                    overlayEntry?.remove();
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 400,
              right: 10,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: ScreenUtils.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((String choice) {
                      final bool isSelected = selectedValue.value == choice;
                      return InkWell(
                        onTap: () async {
                          selectedValue.value = choice;
                          final controller = Get.find<ProfileController>();
                          controller.updateDifficultyLevel(choice);
                          // Add backend save
                          try {
                            final authService = Get.find<AuthService>();
                            await authService.updateUserPreferences(
                                difficultyLevel: choice);
                          } catch (e) {
                            print('Error updating difficulty: $e');
                          }
                          overlayEntry?.remove();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEAF1FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                choice,
                                style: const TextStyle(
                                  color: Color(0xFF616161),
                                  fontSize: 14,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Colors.redAccent, size: 18),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/difficulty.png',
                    width: 21,
                    height: 21,
                    color: Color(0xFF4D84F7),
                  ),
                  SizedBox(width: ScreenUtils.width * 0.028),
                  Text(
                    'difficulty',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF172B75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: GestureDetector(
                  onTap: () => _showCustomDropdown(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedValue.value.isEmpty ? ' ' : selectedValue.value,
                        style: const TextStyle(
                            color: Color(0xFF616161),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(width: ScreenUtils.width * 0.012),
                      Icon(Icons.keyboard_arrow_down_sharp,
                          color: Color(0xFF4D84F7)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// Community Preference Widget
class CommunityPreferenceWidget extends StatelessWidget {
  final RxString selectedValue;
  final List<String> options;

  const CommunityPreferenceWidget({
    super.key,
    required this.selectedValue,
    required this.options,
  });

  void _showCustomDropdown(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
            button.localToGlobal(Offset.zero),
            button.localToGlobal(button.size.bottomRight(Offset.zero),
                ancestor: overlay)),
        Offset.zero & overlay.size);

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: GestureDetector(
                  onTap: () {
                    overlayEntry?.remove();
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 400,
              right: 10,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: ScreenUtils.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((String choice) {
                      final bool isSelected = selectedValue.value == choice;
                      return InkWell(
                        onTap: () async {
                          selectedValue.value = choice;
                          final controller = Get.find<ProfileController>();
                          controller.updateCommunityAccess(choice);

                          try {
                            final authService = Get.find<AuthService>();
                            await authService.updateUserPreferences(
                              communityAccess:
                                  choice == 'In' ? 'Public' : 'Private',
                            );
                          } catch (e) {
                            print('Error updating community: $e');
                          }

                          overlayEntry?.remove();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEAF1FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                choice,
                                style: const TextStyle(
                                  color: Color(0xFF616161),
                                  fontSize: 14,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Colors.redAccent, size: 18),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/community.png',
                    width: 19,
                    height: 16,
                    color: Color(0xFF4D84F7),
                  ),
                  SizedBox(width: ScreenUtils.width * 0.028),
                  Text(
                    'community',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF172B75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: GestureDetector(
                  onTap: () => _showCustomDropdown(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedValue.value.isEmpty ? ' ' : selectedValue.value,
                        style: const TextStyle(
                            color: Color(0xFF616161),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(width: ScreenUtils.width * 0.012),
                      Icon(Icons.keyboard_arrow_down_sharp,
                          color: Color(0xFF4D84F7)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// Notifications Preference Widget
class NotificationsPreferenceWidget extends StatelessWidget {
  final RxString selectedValue;
  final List<String> options;

  const NotificationsPreferenceWidget({
    super.key,
    required this.selectedValue,
    required this.options,
  });

  void _showCustomDropdown(BuildContext context) {
    final controller = Get.find<ProfileController>();
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
            button.localToGlobal(Offset.zero),
            button.localToGlobal(button.size.bottomRight(Offset.zero),
                ancestor: overlay)),
        Offset.zero & overlay.size);

    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                child: GestureDetector(
                  onTap: () {
                    overlayEntry?.remove();
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 400,
              right: 10,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: ScreenUtils.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((String choice) {
                      final bool isSelected =
                          controller.selectedNotifications.value == choice;

                      return InkWell(
                        onTap: () async {
                          final controller = Get.find<ProfileController>();

                          controller.selectedNotifications.value = choice;
                          controller.updateNotifications(choice == 'Allowed');

                          try {
                            final authService = Get.find<AuthService>();
                            await authService.updateUserPreferences(
                              notificationsEnabled: choice == 'Allowed',
                            );
                          } catch (e) {
                            print('Error updating notifications: $e');
                          }

                          overlayEntry?.remove();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFEAF1FF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                choice,
                                style: const TextStyle(
                                  color: Color(0xFF616161),
                                  fontSize: 14,
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Colors.redAccent, size: 18),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/icons/notification.png',
                    width: 12,
                    height: 19,
                    color: Color(0xFF4D84F7),
                  ),
                  SizedBox(width: ScreenUtils.width * 0.028),
                  Text(
                    'notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF172B75),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 0),
                child: GestureDetector(
                  onTap: () => _showCustomDropdown(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.selectedNotifications.value,
                        style: const TextStyle(
                            color: Color(0xFF616161),
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(width: ScreenUtils.width * 0.012),
                      Icon(Icons.keyboard_arrow_down_sharp,
                          color: Color(0xFF4D84F7)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// Individual Info Row Widgets for each preference type

// Category Info Row Widget
class CategoryInfoRow extends StatelessWidget {
  final String value;

  const CategoryInfoRow({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/icons/category.png',
            width: 17,
            height: 17,
          ),
          SizedBox(width: ScreenUtils.width * 0.024),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 3,
                  child: Text('Category',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF172B75),
                          fontSize: 12)),
                ),
                Spacer(),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: SizedBox(
                      width: 140,
                      child: Text(
                        value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFF616161),
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Interests Info Row Widget
class InterestsInfoRow extends StatelessWidget {
  final String value;

  const InterestsInfoRow({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.interests,
            size: 18,
            color: Color(0xFF4D84F7),
          ),
          const SizedBox(width: 11.5),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: Text(
                    'Interests',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF172B75),
                        fontSize: 12),
                  ),
                ),
                Spacer(),
                Obx(() {
                  final controller = Get.find<ProfileController>();
                  return Center(
                    child: SizedBox(
                      width: 100,
                      child: Text(
                        controller.selectedTopics.value.isEmpty
                            ? 'No interests selected'
                            : controller.selectedTopics.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFF616161),
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Topics Info Row Widget
class TopicsInfoRow extends StatelessWidget {
  final String value;

  const TopicsInfoRow({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 2.5,
          ),
          Image.asset(
            'assets/icons/topics.png',
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 11.5),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: Text(
                    'Topics',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF172B75),
                        fontSize: 12),
                  ),
                ),
                Spacer(),
                Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      color: Color(0xFF616161),
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Difficulty Info Row Widget
class DifficultyInfoRow extends StatelessWidget {
  final String value;

  const DifficultyInfoRow({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/icons/difficulty.png',
            width: 17,
            height: 16,
          ),
          SizedBox(width: ScreenUtils.width * 0.024),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: Text('Difficulty',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF172B75),
                          fontSize: 12)),
                ),
                Spacer(),
                Obx(() => Expanded(
                      flex: 3,
                      child: Center(
                        child: SizedBox(
                          width: 140,
                          child: Text(
                            controller.user.value?.difficultyLevel ?? 'N/A',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Color(0xFF616161),
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Community Info Row Widget
class CommunityInfoRow extends StatelessWidget {
  final String value;

  const CommunityInfoRow({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/icons/community.png',
            width: 17,
            height: 16,
          ),
          SizedBox(width: ScreenUtils.width * 0.025),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: Text('Community',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF172B75),
                          fontSize: 12)),
                ),
                Spacer(),
                Obx(() => Flexible(
                      flex: 1,
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          child: Text(
                            controller.user.value?.communityAccess ?? 'N/A',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: Color(0xFF616161),
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Notifications Info Row Widget
class NotificationsInfoRow extends StatelessWidget {
  final String value;

  const NotificationsInfoRow({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/icons/notification.png',
            width: 12,
            height: 19,
          ),
          SizedBox(width: ScreenUtils.width * 0.036),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: Text('Notifications',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF172B75),
                          fontSize: 12)),
                ),
                Spacer(),
                Obx(() => Expanded(
                      flex: 1,
                      child: Center(
                        child: SizedBox(
                          width: 120,
                          child: Text(
                            controller.user.value?.notificationsEnabled == true
                                ? 'Allowed'
                                : 'Blocked',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: Color(0xFF616161),
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
