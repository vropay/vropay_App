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




  // Go back to the previous screen
  void goBack() {
    Get.back();
  }
}
