import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/profile/widgets/sign_out.dart';
import '../../../../../Components /bottom_navbar.dart';
import '../../../../../Components /top_navbar.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';

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
              Obx(() =>
                  _ProfileSection(isEditMode: controller.isGeneralEditMode.value)),
              const SizedBox(height: 20),
              Obx(() =>
                  _PreferencesSection(isEditMode: controller.isPreferencesEditMode.value)),
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
                        'SIGN OUT?',
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
                        'DEACTIVATE?',
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
      bottomNavigationBar: CustomBottomNavBar(
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
              // Top right edit/done
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: controller.isGeneralEditMode,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isEditMode ? 'Done' : 'Edit',
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
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.transparent,
                    child: Image.asset(
                      'assets/icons/avatar.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 70),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: isEditMode
                                  ? TextFormField(
                                      controller:
                                          controller.firstNameController,
                                      decoration: const InputDecoration(
                                          labelText: 'First'),
                                    )
                                  : Text('First',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF172B75))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: isEditMode
                                  ? TextFormField(
                                      controller: controller.lastNameController,
                                      decoration: const InputDecoration(
                                          labelText: 'Last'),
                                    )
                                  : Text('Last',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF172B75))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: !isEditMode
                                  ? Text(
                                controller.firstNameController.text.isEmpty
                                    ? "Vikas"
                                    : controller.firstNameController.text,
                                style: const TextStyle(fontSize: 16),
                              )
                                  : const SizedBox(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: !isEditMode
                                  ? Text(
                                controller.lastNameController.text.isEmpty
                                    ? "Raika"
                                    : controller.lastNameController.text,
                                style: const TextStyle(fontSize: 16),
                              )
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              isEditMode
                  ? TextFormField(
                      controller: controller.phoneController,
                      decoration: const InputDecoration(labelText: 'Mob No'),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_android_outlined,
                              color: Color(0xFF83A5FA),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text('Mob No',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text(controller.phoneController.text.isEmpty
                            ? ' '
                            : controller.phoneController.text),
                      ],
                    ),
              SizedBox(
                height: 10,
              ),
              // Email
              isEditMode
                  ? TextFormField(
                      controller: controller.emailController,
                      decoration: const InputDecoration(labelText: 'Email ID'),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: Color(0xFF83A5FA),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text('Email id',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF172B75))),
                          ],
                        ),
                        Text(controller.emailController.text.isEmpty
                            ? ' '
                            : controller.emailController.text),
                      ],
                    ),
              SizedBox(
                height: 10,
              ),
              // Gender
              isEditMode
                  ? Obx(() => DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Gender'),
                        value: controller.selectedGender.value,
                        items: controller.genderOptions
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null)
                            controller.selectedGender.value = value;
                        },
                      ))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person_outlined,
                              color: Color(0xFF83A5FA),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text('Gender',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF172B75))),
                          ],
                        ),
                        Text(controller.selectedGender.value.isEmpty
                            ? ' '
                            : controller.selectedGender.value),
                      ],
                    ),
            ],
          ),
        ),

        // Capsule label
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
                color: const Color(0xFF714FC0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'General',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
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
      ('assets/icons/category.png', 'Category', 'Business owner'),
      ('assets/icons/topics.png', 'Topics', 'Selected'),
      ('assets/icons/difficulty.png', 'Difficulty', 'Advance'),
      ('assets/icons/community.png', 'Community', 'In'),
      ('assets/icons/notification.png', 'Notifications', 'Allowed'),
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
                  onTap: controller.isPreferencesEditMode,
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
                        color: Colors.red, // Optional: tint the icon
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (var item in items)
                isEditMode
                    ? _EditableField(label: item.$2, value: item.$3)
                    : _InfoRow(
                        iconPath: item.$1, label: item.$2, value: item.$3),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF714FC0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: const Text(
                  'Preferences',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
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

class _EditableField extends StatelessWidget {
  final String label;
  final String value;

  const _EditableField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: value,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
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
                  fontSize: 16,
                ),
              ),
              const Text(
                'trial ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'ending soon',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 20),
              const Text(
                'upgrade',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.double_arrow_outlined, color: Colors.white, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
