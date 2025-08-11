import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ProfileController extends GetxController {
  final RxBool isGeneralEditMode = false.obs;
  final RxBool isPreferencesEditMode = false.obs;

  final firstNameController = TextEditingController(text: 'Vikas');
  final lastNameController = TextEditingController(text: 'Raika');
  final phoneController = TextEditingController(text: '0245814170');
  final emailController = TextEditingController(text: 'vikas67@xyz.com');

  final genderOptions = ['Male', 'Female', 'Other'];
  final selectedGender = 'Male'.obs;

  void saveGeneralProfile() {
    /// include logic to send to backend or local storage here.
    debugPrint('Saved General Info: '
        '${firstNameController.text} '
        '${lastNameController.text} '
        '${phoneController.text} '
        '${emailController.text} '
        '${selectedGender.value}');
  }
  final categoryOptions = ['Business owner', 'Student', 'Working Professional'];
  final topicsOptions = ['Selected', 'All', 'None'];
  final difficultyOptions = ['Beginner', 'Intermediate', 'Advance'];
  final communityOptions = ['In', 'Out'];
  final notificationOptions = ['Allowed', 'Blocked'];

  final categoryIcons = {
    'Student': Image.asset('assets/icons/student.png'),
    'Working Professional': Image.asset('assets/icons/student.png'),
    'Business owner': Image.asset('assets/icons/student.png'),
  };


  final selectedCategory = 'Business owner'.obs;
  final selectedTopics = 'Selected'.obs;
  final selectedDifficulty = 'Advance'.obs;
  final selectedCommunity = 'In'.obs;
  final selectedNotifications = 'Allowed'.obs;

  void savePreferences() {
    debugPrint('Preferences saved:\n'
        'Category: ${selectedCategory.value}\n'
        'Topics: ${selectedTopics.value}\n'
        'Difficulty: ${selectedDifficulty.value}\n'
        'Community: ${selectedCommunity.value}\n'
        'Notifications: ${selectedNotifications.value}');
  }
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
