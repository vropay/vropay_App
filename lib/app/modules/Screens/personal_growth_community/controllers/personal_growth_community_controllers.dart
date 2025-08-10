import 'package:get/get.dart';

class PersonalGrowthCommunityController extends GetxController {
  final isLoading = false.obs;
  final selectedCategory = ''.obs;
  final articles = <Map<String, dynamic>>[].obs;

  // Categories for personal growth
  final categories = [
    'entrepreneurship',
    'visionaries',
    'law',
    'books',
    'vocab',
    'health',
    'spirituality',
    'quantumleap',
    'geeta gyan',
    'vedic wise'
  ].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Go back to the previous screen
  void goBack() {
    Get.back();
  }
}
