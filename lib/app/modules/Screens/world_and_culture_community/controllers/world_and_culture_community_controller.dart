import 'package:get/get.dart';

class WorldAndCultureCommunityController extends GetxController {
  final isLoading = false.obs;
  final selectedCategory = ''.obs;
  final articles = <Map<String, dynamic>>[].obs;

  // Categories for world and culture
  final categories = [
    'news',
    'history',
    'travel',
    'astrology',
    'art',
    'music',
    'usa',
    'nature',
    'podcast',
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
