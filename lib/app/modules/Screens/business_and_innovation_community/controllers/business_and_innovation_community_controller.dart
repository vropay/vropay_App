import 'package:get/get.dart';

class BusinessInnovationCommunityController extends GetxController {
  final isLoading = false.obs;
  final selectedCategory = ''.obs;
  final articles = <Map<String, dynamic>>[].obs;

  // Categories for business and innovation
  final categories = [
    'startup',
    'investing',
    'finance',
    'stocks',
    'tech',
    'ai tools',
    'hustle',
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
