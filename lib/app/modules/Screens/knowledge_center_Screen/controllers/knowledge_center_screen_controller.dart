import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/knowledge_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class KnowledgeCenterScreenController extends GetxController {
  final KnowledgeService _knowledgeService = Get.find<KnowledgeService>();

  // Observable variables
  final RxList<dynamic> topics = <dynamic>[].obs;
  final RxList<dynamic> subtopics = <dynamic>[].obs;
  final RxList<dynamic> contents = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedTopicId = ''.obs;
  final RxString selectedSubtopicId = ''.obs;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    loadKnowledgeCenter();
  }

  // Load knowledge center data
  Future<void> loadKnowledgeCenter() async {
    try {
      isLoading.value = true;

      final response = await _knowledgeService.getKnowledgeCenter();

      if (response.success && response.data != null) {
        final raw = response.data!['topics'];
        topics.value = raw is List ? raw : [];
        print('✅ Topics loaded: ${topics.length}');
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load knowledge center: ${e.toString()}');
      print('❌ Knowledge center error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // load subtopics for a topic
  Future<void> loadSubtopics(String topicId) async {
    try {
      isLoading.value = true;
      selectedTopicId.value = topicId;

      final response = await _knowledgeService.getSubTopicContents(topicId);

      if (response.success && response.data != null) {
        final raw = response.data!['subtopics'];
        subtopics.value = raw is List ? raw : [];
        print('✅ Loaded ${subtopics.length} subtopics for topic: $topicId');
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load subtopics: ${e.toString()}');
      print('❌ Load subtopics error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load contents for a subtopic
  Future<void> loadContents(String subtopicId) async {
    try {
      isLoading.value = true;
      selectedSubtopicId.value = subtopicId;

      final response = await _knowledgeService.getSubTopicContents(subtopicId);

      if (response.success && response.data != null) {
        final raw = response.data!['contents'];
        contents.value = raw is List ? raw : [];
        print('✅ Loaded ${contents.length} contents for subtopic: $subtopicId');
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load contents: ${e.toString()}');
      print('❌ Load contents error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // navigate to content details
  void navigateToContent(String contentId) {
    Get.toNamed(Routes.NEWS_DETAILS_SCREEN,
        arguments: {'contentId': contentId});
  }

  // Navigate to subtopic community
  void navigateToSubtopicCommunity(String subtopicId) {
    Get.toNamed(Routes.WORLD_AND_CULTURE_COMMUNITY_SCREEN,
        arguments: {'subtopicId': subtopicId});
  }
}
