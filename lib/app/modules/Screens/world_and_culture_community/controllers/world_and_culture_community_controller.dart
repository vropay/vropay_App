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

  // Go back to the previous screen
  void goBack() {
    Get.back();
  }
}
