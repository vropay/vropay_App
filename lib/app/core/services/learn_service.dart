import 'package:get/get.dart';
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
import 'package:vropay_final/app/core/network/api_client.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';

class LearnService extends GetxService {
  final ApiClient _api = ApiClient();
  final RxBool isLoading = false.obs;

  Future<ApiResponse<Map<String, dynamic>>> getMainCategories() async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Getting main categories from: ${ApiConstants.learnMainCategories}');
      print(
          '🔗 Full URL: ${ApiConstants.baseUrl}${ApiConstants.learnMainCategories}');

      final res = await _api.get(ApiConstants.learnMainCategories);
      print('✅ LearnService - Raw response: ${res.data}');
      print('✅ LearnService - Response status: ${res.statusCode}');

      final data = _unwrap(res.data);
      print('🔍 LearnService - Unwrapped data: $data');

      final list = _asListOfMap(data);
      print('📋 LearnService - Parsed list length: ${list.length}');

      return ApiResponse.success({'items': list});
    } catch (e) {
      print('❌ LearnService - Error: $e');
      print('❌ LearnService - Error type: ${e.runtimeType}');

      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getMainCategoryById(
      String id) async {
    try {
      isLoading.value = true;
      print('🚀 LearnService - Getting main category by ID: $id');

      final res = await _api.get(ApiConstants.learnMainCategoryById(id));
      print('✅ LearnService - Category response: ${res.data}');

      final data = _unwrap(res.data);
      return ApiResponse.success(data);
    } catch (e) {
      print('❌ LearnService - Category error: $e');

      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getSubCategories(
      String mainId) async {
    try {
      isLoading.value = true;
      print('🚀 LearnService - Getting subcategories for mainId: $mainId');

      final res = await _api.get(ApiConstants.learnSubCategories(mainId));
      print('✅ LearnService - Subcategories response: ${res.data}');

      final data = _unwrap(res.data);
      final list = _asListOfMap(data);
      return ApiResponse.success({'items': list});
    } catch (e) {
      print('❌ LearnService - Subcategories error: $e');

      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getTopics(
      String mainId, String subId) async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Getting topics for mainId: $mainId, subId: $subId');

      final res = await _api.get(ApiConstants.learnTopics(mainId, subId));
      print('✅ LearnService - Topics response: ${res.data}');

      final data = _unwrap(res.data);
      final list = _asListOfMap(data);
      return ApiResponse.success({'items': list});
    } catch (e) {
      print('❌ LearnService - Topics error: $e');

      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getEntries(
      String mainId, String subId, String topicId) async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Getting entries for mainId: $mainId, subId: $subId, topicId: $topicId');

      final res =
          await _api.get(ApiConstants.learnEntries(mainId, subId, topicId));
      print('✅ LearnService - Entries response: ${res.data}');

      final data = _unwrap(res.data);
      final list = _asListOfMap(data);
      return ApiResponse.success({'items': list});
    } catch (e) {
      print('❌ LearnService - Entries error: $e');

      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Helpers to tolerate {success, data} and raw arrays
  dynamic _unwrap(dynamic raw) {
    print(
        '🔍 LearnService - Unwrapping raw data: $raw (type: ${raw.runtimeType})');

    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw;
      print('🔍 LearnService - Extracted data: $data');
      return data;
    }
    return raw;
  }

  List<Map<String, dynamic>> _asListOfMap(dynamic data) {
    print(
        '🔍 LearnService - Converting to list: $data (type: ${data.runtimeType})');

    if (data is List) {
      final list = List<Map<String, dynamic>>.from(
        data.where((e) => e is Map<String, dynamic>),
      );
      print('📋 LearnService - Converted list: $list');
      return list;
    }
    print('⚠️ LearnService - Data is not a list, returning empty list');

    return <Map<String, dynamic>>[];
  }

  Exception _handle(dynamic e) {
    if (e is ApiException) {
      return e;
    }
    return UnknownException('LearnService error: ${e.toString()}');
  }
}
