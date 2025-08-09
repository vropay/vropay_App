import 'package:get/get.dart';

class NewsController extends GetxController {
  final isLoading = false.obs;
  final selectedNews = ''.obs;
  final searchText = ''.obs;
  final isGridView = false.obs;
  final selectedFilter = 'All'.obs;
  final showBlur = false.obs;

  // News articles - only the exact text provided
  final newsArticles = [
    {
      'title': 'Trump greenlights "massive" arms deal for Ukraine',
      'thumbnail': '',
      'keyword': 'Politics',
    },
    {
      'title': 'Tesla launches first Mumbai showroom (BKC)',
      'thumbnail': '',
      'keyword': 'Business',
    },
    {
      'title': 'SBI cuts lending rates',
      'thumbnail': '',
      'keyword': 'Finance',
    },
    {
      'title': 'India\'s inflation hits 6-year low',
      'thumbnail': '',
      'keyword': 'Economy',
    },
    {
      'title': 'Astronaut splashdown success',
      'thumbnail': '',
      'keyword': 'Science',
    },
    {
      'title': 'Congress demands full J&K statehood',
      'thumbnail': "assets/icons/thumbnail.png",
      'keyword': 'Politics',
    },
    {
      'title': 'China & EU move to normalize diplomatic ties',
      'thumbnail': '',
      'keyword': 'International',
    },
  ].obs;

  // Get filtered news based on search text
  List<Map<String, dynamic>> get filteredNews {
    if (searchText.value.isEmpty) {
      return newsArticles;
    }
    return newsArticles.where((news) {
      return news['title']
          .toString()
          .toLowerCase()
          .contains(searchText.value.toLowerCase());
    }).toList();
  }

  // Update search text
  void updateSearchText(String text) {
    searchText.value = text;
  }

  // Clear search
  void clearSearch() {
    searchText.value = '';
  }

  // Toggle view mode
  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

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
