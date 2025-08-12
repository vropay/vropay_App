import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components/bottom_navbar.dart';
import 'package:vropay_final/Components/top_navbar.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/profile/widgets/sign_out.dart';

import '../../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/blueEditableField.dart';
import '../widgets/dropdown_preferences.dart';
import '../widgets/infoRow.dart';
import '../widgets/interestTopics.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(ScreenUtils.height * 0.15),
          child: CustomTopNavBar(selectedIndex: null)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() => _ProfileSection(
                isEditMode: controller.isGeneralEditMode.value)),
            SizedBox(height: ScreenUtils.height * 0.02),
            Obx(() => _PreferencesSection(
                isEditMode: controller.isPreferencesEditMode.value)),
            SizedBox(height: ScreenUtils.height * 0.02),
            _SubscriptionBanner(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4D84F7),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      Get.dialog(SignOutDialog());
                    },
                    child: Text(
                      'SIGN OUT',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4D84F7),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      Get.toNamed(Routes.DEACTIVATE_SCREEN);
                    },
                    child: Text(
                      'DEACTIVATE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final bool isEditMode;

  const _ProfileSection({required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    ScreenUtils.setContext(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Edit/Done button
              GestureDetector(
                onTap: () {
                  if (controller.isGeneralEditMode.value) {
                    controller.saveGeneralProfile();
                  }
                  controller.isGeneralEditMode.toggle();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isEditMode ? 'done' : 'edit',
                      style: const TextStyle(
                          color: Color(0xFF616161),
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: ScreenUtils.width * 0.02),
                    Image.asset(
                      'assets/icons/profileEdit.png',
                      width: ScreenUtils.width * 0.03,
                      height: ScreenUtils.height * 0.03,
                      color: Color(0xFFEF2D56),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ScreenUtils.height * 0.04),

              // Avatar & Name
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.transparent,
                      child: Image.asset(
                        'assets/icons/avatar.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenUtils.width * 0.05),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'First',
                                    style: TextStyle(
                                        fontWeight: isEditMode
                                            ? FontWeight.w400
                                            : FontWeight.w600,
                                        color: Color(0xFF172B75)),
                                  ),
                                  SizedBox(height: ScreenUtils.height * 0.015),
                                  isEditMode
                                      ? BlueEditableField(
                                          controller:
                                              controller.firstNameController,
                                          hint: 'Vikas',
                                        )
                                      : Text(
                                          controller.firstNameController.text,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isEditMode
                                                  ? FontWeight.w400
                                                  : FontWeight.w600,
                                              color: Color(0xFF616161)),
                                        ),
                                ],
                              ),
                            ),
                            SizedBox(
                                width: isEditMode
                                    ? ScreenUtils.width * 0.1
                                    : ScreenUtils.width * 0.01),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Last',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: ScreenUtils.height * 0.015),
                                  isEditMode
                                      ? BlueEditableField(
                                          controller:
                                              controller.lastNameController,
                                          hint: 'raika',
                                        )
                                      : Text(
                                          controller.lastNameController.text,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isEditMode
                                                  ? FontWeight.w400
                                                  : FontWeight.w600,
                                              color: Color(0xFF616161)),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ScreenUtils.height * 0.01),
                        if (isEditMode)
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '3 time changes ',
                                  style: TextStyle(
                                    color: Color(0xFF00B8F0),
                                    fontSize: 8,
                                  ),
                                ),
                                TextSpan(
                                  text: 'allowed',
                                  style: TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtils.height * 0.02),

              // Phone
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoFieldRow(
                    icon: Icons.phone_android_outlined,
                    label: 'Mob no',
                    value: controller.phoneController.text,
                    isEditMode: isEditMode,
                    editChild: BlueEditableField(
                      controller: controller.phoneController,
                      hint: '0245814170',
                    ),
                    helper: null,
                  ),
                  if (isEditMode)
                    Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtils.width * 0.45, top: 4),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'otp - verification ',
                              style: TextStyle(
                                fontSize: 8,
                                color: Color(0xFF00B8F0),
                              ),
                            ),
                            TextSpan(
                              text: 'needed',
                              style: TextStyle(
                                fontSize: 8,
                                color: Color(0xFF616161),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),

              SizedBox(height: isEditMode ? 16 : 28),

              // Email
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InfoFieldRow(
                    icon: Icons.email_outlined,
                    label: 'Email id',
                    value: controller.emailController.text,
                    isEditMode: isEditMode,
                    editChild: BlueEditableField(
                      controller: controller.emailController,
                      hint: 'vikas67@xyz.com',
                    ),
                    helper: null,
                  ),
                  if (isEditMode)
                    Padding(
                      padding: EdgeInsets.only(
                          left: ScreenUtils.width * 0.45, top: 4),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'otp - verification ',
                              style: TextStyle(
                                fontSize: 8,
                                color: Color(0xFF00B8F0),
                              ),
                            ),
                            TextSpan(
                              text: 'needed',
                              style: TextStyle(
                                fontSize: 8,
                                color: Color(0xFF616161),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),

              SizedBox(height: isEditMode ? 16 : 28),

              // Gender
              isEditMode
                  ? DropdownPreference(
                      label: 'Gender',
                      options: controller.genderOptions,
                      selectedValue: controller.selectedGender,
                      iconPath: 'assets/icons/gender.png',
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          // Left: icon + label
                          Row(
                            children: [
                              Image.asset(
                                KImages.profile2Icon,
                                height: 22,
                              ),
                              SizedBox(width: ScreenUtils.width * 0.06),
                              Text(
                                'Gender',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF172B75),
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Text(
                            controller.selectedGender.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF616161),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: ScreenUtils.width * 0.06),
                        ],
                      ),
                    ),
            ],
          ),
        ),

        // Capsule Label
        Positioned(
          top: 24,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: ScreenUtils.width * 0.4,
              height: ScreenUtils.height * 0.05,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isEditMode ? Colors.white : const Color(0xFF714FC0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  isEditMode ? 'general' : 'General',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w300,
                      color: isEditMode ? Color(0xFF172B75) : Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  final bool isEditMode;
  const _PreferencesSection({required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    final items = [
      (
        'assets/icons/category.png',
        'Category',
        controller.categoryOptions,
        controller.selectedCategory
      ),
      (
        'assets/icons/topics.png',
        'Topics',
        controller.topicsOptions,
        controller.selectedTopics
      ),
      (
        'assets/icons/difficulty.png',
        'Difficulty',
        controller.difficultyOptions,
        controller.selectedDifficulty
      ),
      (
        'assets/icons/community.png',
        'Community',
        controller.communityOptions,
        controller.selectedCommunity
      ),
      (
        'assets/icons/notification.png',
        'Notifications',
        controller.notificationOptions,
        controller.selectedNotifications
      ),
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  if (controller.isPreferencesEditMode.value) {
                    controller.savePreferences();
                  }
                  controller.isPreferencesEditMode.toggle();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditMode ? 'done' : 'edit',
                      style: const TextStyle(
                          color: Color(0xFF616161),
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: ScreenUtils.width * 0.01),
                    Image.asset(
                      'assets/icons/profileEdit.png',
                      width: ScreenUtils.width * 0.03,
                      height: ScreenUtils.height * 0.03,
                      color: Color(0xFFEF2D56),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ScreenUtils.height * 0.02),
              for (var item in items)
                Padding(
                  padding: EdgeInsets.only(bottom: isEditMode ? 12 : 20),
                  child: item.$2 == 'Topics' && isEditMode
                      ? GestureDetector(
                          onTap: () {
                            if (!Get.isRegistered<HomeController>()) {
                              Get.put(HomeController());
                            }
                            showDialog(
                              context: context,
                              builder: (context) => InterestSelectionDialog(
                                homeController: Get.find<HomeController>(),
                                selectedValue: item.$4,
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    item.$1,
                                    width: 16,
                                    height: 16,
                                    color: Color(0xFF4D84F7),
                                  ),
                                  SizedBox(width: ScreenUtils.width * 0.04),
                                  Text(
                                    item.$2,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF172B75),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    item.$4.value.isEmpty
                                        ? 'Selected'
                                        : 'Selected',
                                    style: TextStyle(color: Color(0xFF616161)),
                                  ),
                                  SizedBox(width: ScreenUtils.width * 0.01),
                                  Icon(Icons.keyboard_arrow_down_sharp,
                                      color: Color(0xFF4D84F7)),
                                ],
                              ),
                            ],
                          ),
                        )
                      : isEditMode
                          ? DropdownPreference(
                              label: item.$2,
                              options: item.$3,
                              selectedValue: item.$4,
                              iconPath: item.$1,
                            )
                          : _InfoRow(
                              iconPath: item.$1,
                              label: item.$2,
                              value: item.$4.value,
                            ),
                ),
            ],
          ),
        ),
        Positioned(
          top: 24,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: ScreenUtils.width * 0.5,
              height: ScreenUtils.height * 0.05,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isEditMode ? Colors.white : const Color(0xFF714FC0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  isEditMode ? 'preferences' : 'Preferences',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                      color: isEditMode ? Color(0xFF714FC0) : Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String iconPath;
  final String label;
  final String value;

  const _InfoRow({
    required this.iconPath,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            iconPath,
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 3,
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
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

class _SubscriptionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtils.height * 0.15,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF2D56),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'subscription',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white, fontWeight: FontWeight.w400, fontSize: 30),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtils.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'free trial ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    TextSpan(
                      text: 'ending soon',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: ScreenUtils.width * 0.05),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/payments');
                },
                child: Row(
                  children: [
                    SizedBox(width: ScreenUtils.width * 0.05),
                    const Text(
                      'upgrade',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: ScreenUtils.width * 0.01),
                    Image.asset(
                      KImages.doubleArrowIcon,
                      color: Colors.white,
                      width: 30,
                      height: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
