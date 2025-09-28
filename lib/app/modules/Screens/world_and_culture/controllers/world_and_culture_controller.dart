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




  // Go back to the previous screen
  void goBack() {
    Get.back();
  }
}
