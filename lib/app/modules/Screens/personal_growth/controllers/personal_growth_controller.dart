import 'package:get/get.dart';

class PersonalGrowthController extends GetxController {
  final isLoading = false.obs;
  final selectedCategory = ''.obs;
  final articles = <Map<String, dynamic>>[].obs;

  // Categories for personal growth
  final categories = [
    'ENTREPRENEURSHIP',
    'VISIONARIES',
    'LAW',
    'BOOKS',
    'VOCAB',
    'HEALTH',
    'SPIRITUALITY',
    'QUANTUMLEAP',
    'GEETA GYAN',
    'VEDIC WISE'
  ].obs;




  // Go back to the previous screen
  void goBack() {
    Get.back();
  }
}
