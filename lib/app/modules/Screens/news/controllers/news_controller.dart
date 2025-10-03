import 'dart:async';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/learn_service.dart';
import 'package:vropay_final/app/modules/Screens/news/views/news_detail_screen.dart';

class NewsController extends GetxController {
  final LearnService _learnService = Get.find<LearnService>();

  final isLoading = false.obs;
  final selectedNews = ''.obs;
  final searchText = ''.obs;
  final isGridView = false.obs;
  final selectedFilter = 'All'.obs;
  final showBlur = false.obs;

  // Search-related observables
  final isSearching = false.obs;
  final searchResults = <Map<String, dynamic>>[].obs;
  final hasSearchResults = false.obs;
  final searchError = ''.obs;

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
      print('🚀 News - SubCategory ID: $subCategoryId');
      print('🚀 News - Category ID: $categoryId');
    }

    // Load topic-specific news from API
    if (topicId != null && subCategoryId != null && categoryId != null) {
      print('✅ News - All topic parameters available, calling loadTopicNews()');
      loadTopicNews();
    } else {
      // Fallback to static data if no topic provided
      print('⚠️ News - Missing topic parameters, using static data');
      print(
          '⚠️ News - topicId: $topicId, subCategoryId: $subCategoryId, categoryId: $categoryId');
      loadStaticNews();
    }
  }

  // Load topic-specific news from API
  Future<void> loadTopicNews({String? dateFilter}) async {
    try {
      isLoading.value = true;
      print('🚀 News - Loading news for topic: $topicName');
      print(
          '🚀 News - API Parameters: categoryId=$categoryId, subCategoryId=$subCategoryId, topicId=$topicId');
      if (dateFilter != null) {
        print('📅 News - Date filter: $dateFilter');
      }

      final response = await _learnService.getEntries(
          categoryId!, subCategoryId!, topicId!,
          dateFilter: dateFilter);

      print('🔍 News - Response success: ${response.success}');
      print('🔍 News - Response data: ${response.data}');

      if (response.success && response.data != null) {
        final items = response.data!['items'] as List<Map<String, dynamic>>;
        print('🔍 News - Items from response: ${items.length}');
        print('🔍 News - Response data structure: ${response.data}');

        if (items.isNotEmpty) {
          // Apply client-side filtering as fallback if backend doesn't support it
          List<Map<String, dynamic>> filteredItems = items;
          if (dateFilter != null && dateFilter != 'All') {
            print('📅 News - Starting client-side filtering for: $dateFilter');
            filteredItems = _filterItemsByDate(items, dateFilter);
            print(
                '📅 News - Client-side filtering: ${items.length} → ${filteredItems.length} items');

            // If no items match the filter, show all items with a warning
            if (filteredItems.isEmpty) {
              print('⚠️ News - No items match date filter, showing all items');
              filteredItems = items;
            }
          }

          newsArticles.assignAll(filteredItems);
          print('✅ News - Loaded ${newsArticles.length} news articles');

          // Debug: Print first article content
          if (items.isNotEmpty) {
            final firstArticle = items.first;
            print('🔍 News - First article title: ${firstArticle['title']}');
            print('🔍 News - First article body: ${firstArticle['body']}');
            print(
                '🔍 News - First article thumbnail: ${firstArticle['thumbnail']}');
            print('🔍 News - First article image: ${firstArticle['image']}');
            print(
                '🔍 News - First article topic context: topicId=${firstArticle['topicId']}, categoryId=${firstArticle['categoryId']}');

            // Print all article titles to see if they're different
            print('🔍 News - All article titles:');
            for (int i = 0; i < items.length && i < 3; i++) {
              print('  ${i + 1}. ${items[i]['title']}');
            }
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
    print('📰 News - Loading static news data (fallback)');
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

    // If we have search results, use them
    if (hasSearchResults.value && searchResults.isNotEmpty) {
      return searchResults;
    }

    // Otherwise, fall back to local filtering
    return newsArticles.where((news) {
      return news['title']
          .toString()
          .toLowerCase()
          .contains(searchText.value.toLowerCase());
    }).toList();
  }

  // Update search text with debounced search
  void updateSearchText(String text) {
    searchText.value = text;

    // Clear previous search results when text is empty
    if (text.isEmpty) {
      clearSearchResults();
      return;
    }

    // Perform API search if we have topic context
    if (text.length >= 2 &&
        topicId != null &&
        subCategoryId != null &&
        categoryId != null) {
      _performSearch(text);
    }
  }

  // Perform API search with debouncing
  Timer? _searchTimer;
  void _performSearch(String query) {
    // Cancel previous timer
    _searchTimer?.cancel();

    // Set new timer for debounced search
    _searchTimer = Timer(Duration(milliseconds: 500), () {
      if (query == searchText.value) {
        // Ensure query hasn't changed
        searchEntries(query);
      }
    });
  }

  // Search entries via API
  Future<void> searchEntries(String query) async {
    if (topicId == null || subCategoryId == null || categoryId == null) {
      print('❌ News - Cannot search: missing topic context');
      return;
    }

    try {
      isSearching.value = true;
      searchError.value = '';

      print('🔍 News - Searching for: "$query" in topic: $topicId');

      final response = await _learnService.searchEntriesInTopic(
        categoryId!,
        subCategoryId!,
        topicId!,
        query,
        page: 1,
        limit: 20,
      );

      print('🔍 News - Search response success: ${response.success}');
      print('🔍 News - Search response data: ${response.data}');

      if (response.success && response.data != null) {
        final results = response.data!['results'] as List<dynamic>? ?? [];
        final searchItems = results.cast<Map<String, dynamic>>();

        searchResults.assignAll(searchItems);
        hasSearchResults.value = true;

        print('✅ News - Found ${searchItems.length} search results');

        // Debug: Print first result if available
        if (searchItems.isNotEmpty) {
          final firstResult = searchItems.first;
          print('🔍 News - First search result title: ${firstResult['title']}');
          if (firstResult['highlightedTitle'] != null) {
            print(
                '🔍 News - Highlighted title: ${firstResult['highlightedTitle']}');
          }
        }
      } else {
        print('❌ News - Search failed: ${response.message}');
        searchError.value = response.message;
        searchResults.clear();
        hasSearchResults.value = false;
      }
    } catch (e) {
      print('❌ News - Search error: $e');
      searchError.value = 'Search failed. Please try again.';
      searchResults.clear();
      hasSearchResults.value = false;
    } finally {
      isSearching.value = false;
    }
  }

  // Clear search results and return to normal view
  void clearSearchResults() {
    searchResults.clear();
    hasSearchResults.value = false;
    searchError.value = '';
    _searchTimer?.cancel();
  }

  // Clear search
  void clearSearch() {
    searchText.value = '';
    clearSearchResults();
  }

  // Toggle view mode
  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }

  // Handle date filter change
  void onFilterChanged(String filter) {
    selectedFilter.value = filter;
    print('📅 News - Filter changed to: $filter');
    print(
        '📅 News - Topic context: topicId=$topicId, subCategoryId=$subCategoryId, categoryId=$categoryId');

    // Reload news with the new filter
    if (topicId != null && subCategoryId != null && categoryId != null) {
      print('📅 News - Calling loadTopicNews with dateFilter: $filter');
      loadTopicNews(dateFilter: filter);
    } else {
      print('❌ News - Cannot load news: missing topic context');
    }
  }

  // Client-side date filtering as fallback
  List<Map<String, dynamic>> _filterItemsByDate(
      List<Map<String, dynamic>> items, String filter) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (filter.toLowerCase()) {
      case 'today':
        // Only today's news (from start of today to end of today)
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'this week':
        // Last 7 days including today (current day + previous 6 days)
        startDate = now.subtract(Duration(days: 6));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'this month':
        // Last 30 days including today (current day + previous 29 days)
        startDate = now.subtract(Duration(days: 29));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      default:
        return items; // No filtering for unknown filters
    }

    print('📅 News - Client filtering: $startDate to $endDate');
    print('📅 News - Current time: $now');
    print('📅 News - Filter: $filter');
    print(
        '📅 News - Date range duration: ${endDate.difference(startDate).inDays + 1} days');

    List<Map<String, dynamic>> filteredItems = [];
    int processedCount = 0;
    int matchCount = 0;

    for (var item in items) {
      processedCount++;

      // Try different possible date field names
      var createdAt = item['createdAt'] ??
          item['created_at'] ??
          item['date'] ??
          item['timestamp'] ??
          item['publishedAt'] ??
          item['published_at'];

      // Debug: Print item info
      print('📅 News - Item $processedCount: ${item['title']}');
      print('📅 News - Available fields: ${item.keys.toList()}');
      print(
          '📅 News - Date field found: $createdAt (type: ${createdAt.runtimeType})');

      if (createdAt == null) {
        print(
            '⚠️ News - Item has no date field (tried: createdAt, created_at, date, timestamp, publishedAt, published_at)');
        // For items without date, include them in "All" filter but exclude from date filters
        if (filter.toLowerCase() == 'all') {
          filteredItems.add(item);
          matchCount++;
        }
        continue;
      }

      try {
        DateTime itemDate;
        if (createdAt is String) {
          itemDate = DateTime.parse(createdAt);
        } else if (createdAt is DateTime) {
          itemDate = createdAt;
        } else {
          print('❌ News - Unsupported date type: ${createdAt.runtimeType}');
          continue;
        }

        print('📅 News - Parsed item date: $itemDate');

        final isInRange =
            itemDate.isAfter(startDate.subtract(Duration(seconds: 1))) &&
                itemDate.isBefore(endDate.add(Duration(seconds: 1)));

        print('📅 News - Is in range ($startDate to $endDate): $isInRange');

        if (isInRange) {
          filteredItems.add(item);
          matchCount++;
          print(
              '✅ News - Item matches filter: ${item['title']} (${itemDate.toIso8601String()})');
        }
      } catch (e) {
        print('❌ News - Error parsing date for item: $createdAt, error: $e');
        continue;
      }
    }

    print(
        '📅 News - Filtering complete: $processedCount processed, $matchCount matched');
    return filteredItems;
  }

  // Navigate to news detail screen
  void navigateToNewsDetail(Map<String, dynamic> news) {
    print('🚀 News - Navigating to detail screen');
    print('🔍 News - News data: ${news.toString()}');
    print('🔍 News - Title: ${news['title']}');
    print('🔍 News - Has body: ${news['body'] != null}');
    print('🔍 News - Has thumbnail: ${news['thumbnail'] != null}');

    Get.to(() => NewsDetailScreen(news: news));
  }

  // Go back to the previous screen
  void goBack() {
    Get.back();
  }
}
