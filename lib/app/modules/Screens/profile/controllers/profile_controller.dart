import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final RxBool isGeneralEditMode = false.obs;
  final RxBool isPreferencesEditMode = false.obs;

  // Editable fields
  final firstNameController = TextEditingController(text: 'Vikas');
  final lastNameController = TextEditingController(text: 'Raika');
  final phoneController = TextEditingController(text: '0245814170');
  final emailController = TextEditingController(text: 'vikas67@xyz.com');

  // Gender dropdown
  final genderOptions = ['Male', 'Female', 'Other'];
  final selectedGender = 'Male'.obs;


  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
