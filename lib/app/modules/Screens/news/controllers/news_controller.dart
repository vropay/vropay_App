import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/learn_service.dart';

class NewsController extends GetxController {
  final LearnService _learnService = Get.find<LearnService>();

  final isLoading = false.obs;
  final selectedNews = ''.obs;
  final searchText = ''.obs;
  final isGridView = false.obs;
  final selectedFilter = 'All'.obs;
  final showBlur = false.obs;

  // Navigation arguments
  String? topicId;
  String? topicName;
  String? subCategoryId;
  String? categoryId;

  // API-driven news articles
  final RxList<Map<String, dynamic>> newsArticles =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Get arguments from navigation
    final args = Get.arguments;
    if (args != null) {
      topicId = args['topicId']?.toString();
      topicName = args['topicName']?.toString();
      subCategoryId = args['subCategoryId']?.toString();
      categoryId = args['categoryId']?.toString();

      print('🚀 News - Topic ID: $topicId');
      print('🚀 News - Topic Name: $topicName');
    }

    // Load topic-specific news from API
    if (topicId != null && subCategoryId != null && categoryId != null) {
      loadTopicNews();
    } else {
      // Fallback to static data if no topic provided
      loadStaticNews();
    }
  }

  // Load topic-specific news from API
  Future<void> loadTopicNews() async {
    try {
      isLoading.value = true;
      print('🚀 News - Loading news for topic: $topicName');

      final response =
          await _learnService.getEntries(categoryId!, subCategoryId!, topicId!);

      print('🔍 News - Response success: ${response.success}');
      print('🔍 News - Response data: ${response.data}');

      if (response.success && response.data != null) {
        final items = response.data!['items'] as List<Map<String, dynamic>>;
        print('🔍 News - Items from response: ${items.length}');

        if (items.isNotEmpty) {
          newsArticles.assignAll(items);
          print('✅ News - Loaded ${newsArticles.length} news articles');

          // Debug: Print first article content
          if (items.isNotEmpty) {
            final firstArticle = items.first;
            print('🔍 News - First article title: ${firstArticle['title']}');
            print('🔍 News - First article body: ${firstArticle['body']}');
          }
        } else {
          // Database is empty - show user-friendly message
          _showNoDataMessage();
          print('📭 News - No data available for topic: $topicName');
        }
      } else {
        print('❌ News - Failed to load news: ${response.message}');
        _showNoDataMessage();
      }
    } catch (e) {
      print('❌ News - Error loading news: $e');
      _showNoDataMessage();
    } finally {
      isLoading.value = false;
    }
  }

  // Show user-friendly message when no data is available
  void _showNoDataMessage() {
    newsArticles.assignAll([
      {
        'title': 'Currently we have not this type of data',
        'subtitle':
            'We are working on adding more content for this topic. Please check back later.',
        'thumbnail': '',
        'keyword': 'Info',
        'isNoData': true,
      }
    ]);
  }

  // Fallback static news data
  void loadStaticNews() {
    newsArticles.assignAll([
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
    ]);
  }

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

  // Go back to the previous screen
  void goBack() {
    Get.back();
  }
}
