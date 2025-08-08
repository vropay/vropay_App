import 'package:get/get.dart';

class WorldAndCultureController extends GetxController {
  final isLoading = false.obs;
  final selectedCategory = ''.obs;
  final articles = <Map<String, dynamic>>[].obs;

  // Categories for world and culture
  final categories = [
    'NEWS',
    'HISTORY',
    'ASTRO',
    'TRAVEL',
    'ART',
    'MUSIC',
    'USA',
    'NATURE',
    'PODCAST',
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
