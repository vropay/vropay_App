import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components/bottom_navbar.dart';
import 'package:vropay_final/Components/top_navbar.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/modules/Screens/profile/widgets/preference_widgets.dart';
import 'package:vropay_final/app/modules/Screens/profile/widgets/sign_out.dart';

import '../../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';
import '../widgets/blueEditableField.dart';
import '../widgets/dropdown_preferences.dart';
import '../../home/widgets/interestScreen.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final authService = Get.find<AuthService>();
    final screenHeight = MediaQuery.of(context).size.height;

    if (context.mounted) {
      ScreenUtils.setContext(context);
    }

    // Ensure data is loaded when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.user.value == null) {
        print('⚠️ ProfileView - No user data found, triggering reload...');
        controller.loadUserData();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        // Prevent back button from closing main screen
        if (didPop) return;
        // Do nothing - stay on current screen
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF7F7F7),
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(ScreenUtils.height * 0.15),
            child: CustomTopNavBar(selectedIndex: null, isMainScreen: true)),
        body: Obx(() {
          if (controller.isLoading.value ||
              controller.user.value == null ||
              authService.currentUser.value == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              print('🔄 ProfileView - Pull to refresh triggered');
              await controller.loadUserData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(() => _ProfileSection(
                      isEditMode: controller.isGeneralEditMode.value)),
                  SizedBox(height: screenHeight * 0.032),
                  Obx(() => _PreferencesSection(
                      isEditMode: controller.isPreferencesEditMode.value)),
                  SizedBox(height: screenHeight * 0.036),
                  _SubscriptionBanner(),
                  SizedBox(height: screenHeight * 0.030),
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
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.04),
                ],
              ),
            ),
          );
        }),
        bottomNavigationBar: CustomBottomNavBar(),
      ),
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

    return Obx(() {
      final user = controller.user.value;

      // Return loading indicator if user is null
      if (user == null) {
        return Container(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding:
                const EdgeInsets.only(left: 23, right: 7, top: 10, bottom: 26),
            margin: const EdgeInsets.only(top: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    if (isEditMode) {
                      await controller.saveGeneralProfile();
                    }
                    controller.toggleEditMode();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.transparent,
                        backgroundImage: (user.profileImage?.isNotEmpty == true)
                            ? NetworkImage(user.profileImage ?? '')
                            : null,
                        child: (user.profileImage?.isEmpty != false)
                            ? Image.asset('assets/icons/avatar.png',
                                fit: BoxFit.cover)
                            : null,
                      ),
                    ),
                    SizedBox(width: ScreenUtils.width * 0.05),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 48),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('First',
                                          style: TextStyle(
                                              fontWeight: isEditMode
                                                  ? FontWeight.w400
                                                  : FontWeight.w600,
                                              color: Color(0xFF172B75))),
                                      SizedBox(
                                          height: ScreenUtils.height * 0.020),
                                      isEditMode
                                          ? BlueEditableField(
                                              controller: controller
                                                  .firstNameController,
                                              hint: user.firstName ??
                                                  'First Name',
                                            )
                                          : Text(
                                              user.firstName ?? 'N/A',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('Last',
                                          style: TextStyle(
                                              fontWeight: isEditMode
                                                  ? FontWeight.w400
                                                  : FontWeight.w600,
                                              color: Color(0xFF172B75))),
                                      SizedBox(
                                          height: ScreenUtils.height * 0.020),
                                      isEditMode
                                          ? BlueEditableField(
                                              controller:
                                                  controller.lastNameController,
                                              hint:
                                                  user.lastName ?? 'Last Name',
                                            )
                                          : Text(
                                              user.lastName ?? 'N/A',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF616161)),
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (isEditMode) ...[
                              SizedBox(height: ScreenUtils.height * 0.01),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: '3 time changes ',
                                        style: TextStyle(
                                            color: Color(0xFF00B8F0),
                                            fontSize: 8)),
                                    TextSpan(
                                        text: 'allowed',
                                        style: TextStyle(
                                            color: Color(0xFF4B5563),
                                            fontSize: 8)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtils.height * 0.02),
                _buildInfoRow(
                  icon: Icons.phone_android_outlined,
                  label: 'Mob no',
                  value: controller.mobileController.text,
                  controller: controller.mobileController,
                  isEditMode: isEditMode,
                  hint: 'Enter mobile',
                  width: 123,
                ),
                SizedBox(
                    height: isEditMode
                        ? ScreenUtils.height * 0.02
                        : ScreenUtils.height * 0.042),
                _buildInfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email id',
                  value: user.email,
                  controller: controller.emailController,
                  isEditMode: isEditMode,
                  hint: 'Enter email',
                  width: ScreenUtils.width * 0.35,
                ),
                SizedBox(
                    height: isEditMode
                        ? ScreenUtils.height * 0.02
                        : ScreenUtils.height * 0.032),
                isEditMode
                    ? DropdownPreference(
                        label: 'Gender',
                        options: controller.genderOptions,
                        selectedValue: controller.selectedGender,
                        iconPath: 'assets/icons/gender.png',
                      )
                    : _buildStaticRow(
                        iconAsset: KImages.profile2Icon,
                        label: 'Gender',
                        value: user.gender ?? controller.selectedGender.value,
                      ),
                SizedBox(height: ScreenUtils.height * 0.02),
              ],
            ),
          ),
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: ScreenUtils.width * 0.4,
                height: ScreenUtils.height * 0.05,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isEditMode ? Colors.white : const Color(0xFF714FC0),
                  borderRadius: BorderRadius.circular(15),
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
    });
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditMode,
    required String hint,
    required double width,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF83A5FA)),
            SizedBox(width: ScreenUtils.width * 0.04),
            Text(label,
                style: TextStyle(
                  fontWeight: isEditMode ? FontWeight.w400 : FontWeight.w500,
                  color: Color(0xFF172B75),
                )),
            const Spacer(),
            isEditMode
                ? Padding(
                    padding: const EdgeInsets.only(right: 26),
                    child: SizedBox(
                      width: width,
                      height: 30,
                      child: _buildEditableField(hint, controller),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 48),
                    child: SizedBox(
                      width: width,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF616161),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.visible,
                        maxLines: 1,
                      ),
                    ),
                  ),
          ],
        ),
        if (isEditMode)
          Padding(
            padding: EdgeInsets.only(top: 4, right: 48),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: 'otp - verification ',
                      style: TextStyle(fontSize: 8, color: Color(0xFF00B8F0))),
                  TextSpan(
                      text: 'needed',
                      style: TextStyle(fontSize: 8, color: Color(0xFF616161))),
                ],
              ),
            ),
          )
      ],
    );
  }

  Widget _buildStaticRow({
    IconData? icon,
    String? iconAsset,
    required String label,
    required String value,
    bool isExpandable = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: ScreenUtils.width * 0.01),
          Row(
            children: [
              if (icon != null)
                Icon(icon, color: Color(0xFF83A5FA), size: 22)
              else if (iconAsset != null)
                Image.asset(iconAsset, height: 22),
              SizedBox(width: ScreenUtils.width * 0.05),
              Text(label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF172B75),
                  )),
            ],
          ),
          SizedBox(
              width: ScreenUtils.width *
                  (label == 'User ID'
                      ? 0.22
                      : label == 'Joined'
                          ? 0.25
                          : 0.18)),
          isExpandable
              ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 26),
                    child: Text(value,
                        style: TextStyle(
                          fontSize: label == 'User ID' ? 12 : 14,
                          color: Color(0xFF616161),
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(right: 26),
                  child: Text(value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF616161),
                        fontWeight: FontWeight.w600,
                      )),
                ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String hint, TextEditingController controller) {
    return Container(
      constraints: BoxConstraints(
        minHeight: ScreenUtils.height * 0.03,
        maxHeight: ScreenUtils.height * 0.06,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerLeft,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration.collapsed(hintText: hint),
        style: TextStyle(
            fontSize: 14,
            color: Color(0xFF616161),
            fontWeight: FontWeight.w400),
        textAlign: TextAlign.center,
        minLines: 1,
        maxLines: null,
      ),
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
        'Interests',
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
          padding: const EdgeInsets.only(top: 10, right: 7, bottom: 17),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () async {
                  if (controller.isPreferencesEditMode.value) {
                    await controller.savePreferences();
                  }
                  controller.isPreferencesEditMode.toggle();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isEditMode ? 'done' : 'edit',
                        style: const TextStyle(
                            color: Color(0xFF616161),
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                    Image.asset('assets/icons/profileEdit.png',
                        width: ScreenUtils.width * 0.03,
                        height: ScreenUtils.height * 0.03,
                        color: Color(0xFFEF2D56)),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              for (var item in items)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: isEditMode ? 12 : 27,
                    right: isEditMode ? 12 : 43,
                  ),
                  child: item.$2 == 'Interests' && isEditMode
                      ? GestureDetector(
                          onTap: () async {
                            controller.loadInterests();
                            await Get.to(() => InterestsScreen(),
                                arguments: {'fromProfile': true});

                            // Force refresh after returning
                            await controller.loadUserData();
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 22.0, bottom: 5),
                            child: Row(
                              children: [
                                Icon(Icons.interests,
                                    size: 18, color: Color(0xFF83A5FA)),
                                SizedBox(width: ScreenUtils.width * 0.04),
                                Text('Interests',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF172B75),
                                      fontSize: 12,
                                    )),
                                Spacer(),
                                SizedBox(
                                  child: Text('Select',
                                      style:
                                          TextStyle(color: Color(0xFF616161))),
                                ),
                                SizedBox(width: ScreenUtils.width * 0.02),
                                Icon(Icons.keyboard_arrow_down_sharp,
                                    color: Color(0xFF4D84F7)),
                              ],
                            ),
                          ),
                        )
                      : item.$2 == 'Interests'
                          ? Padding(
                              padding: const EdgeInsets.only(left: 22.0),
                              child: Obx(() => _buildInfoRowWidget(
                                  'Interests',
                                  controller.selectedTopics.value.isEmpty
                                      ? 'No interests selected'
                                      : controller.selectedTopics.value)),
                            )
                          : isEditMode
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 22.0, bottom: 5),
                                  child: _buildPreferenceWidget(
                                      item.$2, item.$3, item.$4),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(left: 22.0),
                                  child: Obx(() => _buildInfoRowWidget(
                                      item.$2,
                                      _getDisplayValue(
                                          item.$2, item.$4.value))),
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
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.05,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isEditMode ? Colors.white : const Color(0xFF714FC0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(isEditMode ? 'preferences' : 'Preferences',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                        color: isEditMode ? Color(0xFF714FC0) : Colors.white)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceWidget(
      String label, List<String> options, RxString selectedValue) {
    switch (label) {
      case 'Category':
        return CategoryPreferenceWidget(
            selectedValue: selectedValue, options: options);
      case 'Interests':
        return Container(); // Handled separately
      case 'Difficulty':
        return DifficultyPreferenceWidget(
            selectedValue: selectedValue, options: options);
      case 'Community':
        return CommunityPreferenceWidget(
            selectedValue: selectedValue, options: options);
      case 'Notifications':
        return NotificationsPreferenceWidget(
            selectedValue: selectedValue, options: options);
      default:
        return Container();
    }
  }

  String _getDisplayValue(String label, String value) {
    final controller = Get.find<ProfileController>();
    final user = controller.user.value;

    switch (label) {
      case 'Category':
        return user?.profession ?? 'N/A';
      case 'Interests':
        return controller.selectedTopics.value.isNotEmpty
            ? controller.selectedTopics.value
            : 'No interests selected';
      case 'Difficulty':
        return user?.difficultyLevel ?? 'N/A';
      case 'Community':
        return user?.communityAccess ?? 'N/A';
      case 'Notifications':
        return user?.notificationsEnabled == true ? 'Allowed' : 'Blocked';
      default:
        return value.isNotEmpty ? value : 'N/A';
    }
  }

  Widget _buildInfoRowWidget(String label, String value) {
    final controller = Get.find<ProfileController>();
    switch (label) {
      case 'Category':
        return CategoryInfoRow(value: value);
      case 'Interests':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.menu,
                size: 18,
                color: Color(0xFF4D84F7),
              ),
              SizedBox(width: ScreenUtils.width * 0.024),
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
                    Flexible(
                      flex: 3,
                      child: Obx(() => Center(
                            child: Text(
                              controller.selectedTopics.value.isEmpty
                                  ? 'No selected'
                                  : 'Selected',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                  color: Color(0xFF616161),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 'Difficulty':
        return DifficultyInfoRow(value: value);
      case 'Community':
        return CommunityInfoRow(value: value);
      case 'Notifications':
        return NotificationsInfoRow(value: value);
      default:
        return Container();
    }
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
          Text('subscription',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 30),
              textAlign: TextAlign.center),
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
                            fontWeight: FontWeight.w300)),
                    TextSpan(
                        text: 'ending soon',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 10)),
                  ],
                ),
              ),
              SizedBox(width: ScreenUtils.width * 0.05),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.PAYMENT_SCREEN),
                child: Row(
                  children: [
                    SizedBox(width: ScreenUtils.width * 0.05),
                    const Text('upgrade',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                    SizedBox(width: ScreenUtils.width * 0.01),
                    Image.asset(KImages.doubleArrowIcon,
                        color: Colors.white, width: 30, height: 30),
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
