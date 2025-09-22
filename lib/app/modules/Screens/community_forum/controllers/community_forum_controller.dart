import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/forum_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class CommunityForumController extends GetxController {
  final ForumService _forumService = Get.find<ForumService>();

  // Observable variables
  final RxList<dynamic> categories = <dynamic>[].obs;
  final RxList<dynamic> subtopics = <dynamic>[].obs;
  final RxList<dynamic> rooms = <dynamic>[].obs;
  final RxList<dynamic> messages = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedSubtopicId = ''.obs;
  final RxString selectedRoomId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadForumCategories();
  }

  // Load forum categories
  Future<void> loadForumCategories() async {
    try {
      isLoading.value = true;

      final response = await _forumService.getForumCategories();

      if (response.success && response.data != null) {
        categories.value = response.data!['categories'] ?? [];
        print('✅ Loaded ${categories.length} categories');
      } else {
        Get.snackbar(
            'Error', response.message ?? 'Failed to load forum categories');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load forum categories: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load subtopics for a category
  Future<void> loadSubtopics(String categoryId) async {
    try {
      isLoading.value = true;
      selectedCategoryId.value = categoryId;

      final response =
          await _forumService.getSubtopicCommunityForum(categoryId);

      if (response.success && response.data != null) {
        subtopics.value = response.data!['subtopics'] ?? [];
        print(
            '✅ Loaded ${subtopics.length} subtopics for category: $categoryId');
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to load subtopics');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load subtopics: ${e.toString()}');
      print('❌ Load subtopics error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load rooms for a subtopic
  Future<void> loadRooms(String subtopicId) async {
    try {
      isLoading.value = true;
      selectedSubtopicId.value = subtopicId;

      final response =
          await _forumService.getForumGroupsForSubtopic(subtopicId);

      if (response.success && response.data != null) {
        rooms.value = response.data!['rooms'] ?? [];
        print('✅ Loaded ${rooms.length} rooms for subtopic: $subtopicId');
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to load rooms');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load rooms: ${e.toString()}');
      print('❌ Load rooms error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Post message in a room
  Future<void> postMessage(String roomId, String message) async {
    try {
      isLoading.value = true;

      final response = await _forumService.postMessageInCommunity(
          roomId: roomId, text: message);

      if (response.success) {
        Get.snackbar('Success', 'Message posted successfully');

        // Reload messages
        loadMessages(roomId);
      } else {
        Get.snackbar('Success', response.message ?? 'Failed to post message');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to post message: ${e.toString()}');
      print('❌ Post message error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load messages for a room
  Future<void> loadMessages(String roomId) async {
    try {
      isLoading.value = true;
      selectedRoomId.value = roomId;

      messages.value = [];
      print(" Loading messages for room: $roomId");
    } catch (e) {
      Get.snackbar('Error', 'Failed to load messages: ${e.toString()}');
      print('❌ Load messages error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to room
  void navigateToRoom(String roomId) {
    Get.toNamed(Routes.MESSAGE_SCREEN, arguments: {'roomId': roomId});
  }
}
