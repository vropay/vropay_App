import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vropay_final/Components/bottom_navbar.dart';
import 'package:vropay_final/Components/top_navbar.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTopNavBar(selectedIndex: null),
              const SizedBox(height: 16),
              Obx(() => _ProfileSection(
                  isEditMode: controller.isGeneralEditMode.value)),
              const SizedBox(height: 20),
              Obx(() => _PreferencesSection(
                  isEditMode: controller.isPreferencesEditMode.value)),
              const SizedBox(height: 20),
              _SubscriptionBanner(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4D84F7)),
                      onPressed: () {
                        Get.dialog(SignOutDialog());
                      },
                      child: Text(
                        'SIGN OUT',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4D84F7)),
                      onPressed: () {
                        Get.toNamed(Routes.DEACTIVATE_SCREEN);
                      },
                      child: Text(
                        'DEACTIVATE',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ],
          ),
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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(top: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Edit/Done button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    if (controller.isGeneralEditMode.value) {
                      controller.saveGeneralProfile();
                    }
                    controller.isGeneralEditMode.toggle();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEditMode ? 'done' : 'edit',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/icons/profileEdit.png',
                        width: 16,
                        height: 16,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Avatar & Name
              Row(
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
                  const SizedBox(width: 50),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'First',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              isEditMode
                                  ? BlueEditableField(
                                      controller:
                                          controller.firstNameController,
                                      hint: 'Vikas',
                                    )
                                  : Text(
                                      controller.firstNameController.text,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF616161)),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Last',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              isEditMode
                                  ? BlueEditableField(
                                      controller: controller.lastNameController,
                                      hint: 'raika',
                                    )
                                  : Text(
                                      controller.lastNameController.text,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF616161)),
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isEditMode)
                const Padding(
                  padding: EdgeInsets.only(top: 4.0, left: 100),
                  child: Text(
                    '3 time changes allowed',
                    style: TextStyle(
                      color: Color(0xFF4D84F7),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

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
                    const Padding(
                      padding: EdgeInsets.only(left: 200.0, top: 4),
                      child: Text(
                        'otp - verification needed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4D84F7),
                        ),
                      ),
                    ),
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
                    const Padding(
                      padding: EdgeInsets.only(left: 200.0, top: 4),
                      child: Text(
                        'otp - verification needed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4D84F7),
                        ),
                      ),
                    ),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: icon + label
                          Row(
                            children: [
                              Icon(
                                Iconsax.profile_circle,
                                color: Color(0xFF83A5FA),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Gender',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF172B75),
                                ),
                              ),
                            ],
                          ),
                          // Right: selected value
                          Text(
                            controller.selectedGender.value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),

        // Capsule Label
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 200,
              height: 40,
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
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    if (controller.isPreferencesEditMode.value) {
                      controller.savePreferences();
                    }
                    controller.isPreferencesEditMode.toggle();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isEditMode ? 'done' : 'edit',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 14)),
                      const SizedBox(width: 4),
                      Image.asset(
                        'assets/icons/profileEdit.png',
                        width: 16,
                        height: 16,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
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
                                children: [
                                  Image.asset(item.$1, width: 20, height: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    item.$2,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF172B75),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    item.$4.value.isEmpty
                                        ? 'Selected'
                                        : 'Selected',
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.keyboard_arrow_down_sharp,
                                      color: Color(0xFF83A5FA)),
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
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 200,
              height: 40,
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
      height: 112,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEF2D56),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'subscription',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                fontSize: 30),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'free ',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400),
              ),
              const Text(
                'trial ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Text(
                'ending soon',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/payments');
                },
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    const Text(
                      'upgrade',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.double_arrow_outlined,
                        color: Colors.white, size: 15),
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
