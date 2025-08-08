import 'package:get/get.dart';

class BusinessInnovationController extends GetxController {
  final isLoading = false.obs;
  final selectedCategory = ''.obs;
  final articles = <Map<String, dynamic>>[].obs;

  // Categories for business and innovation
  final categories = [
    'STARTUP',
    'INVESTING',
    'FINANCE',
    'STOCKS',
    'TECH',
    'AI TOOLS',
    'HUSTLE',
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
