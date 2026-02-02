import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as GetX;
import 'package:get_storage/get_storage.dart';
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';
import 'package:vropay_final/Utilities/constants/Colors.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  final GetStorage _storage = GetStorage();
  int _retryCount = 0;
  static const int maxRetries = 3;

  void init() {
    _dio = Dio(BaseOptions(
        baseUrl: ApiConstant.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConstant.connectionTimeout),
        receiveTimeout: Duration(milliseconds: ApiConstant.receiveTimeout),
        headers: ApiConstant.defaultHeaders,
        validateStatus: (status) {
          return status != null && status < 500; // Accept all status code < 500
        }));

    // Add interceptors
    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(),
      _RetryInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  //GET request with retry logic
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      await _checkConnectivity();
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      await _checkConnectivity();
      final response =
          await _dio.post(path, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      await _checkConnectivity();
      final response =
          await _dio.put(path, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(String path,
      {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      await _checkConnectivity();
      final response =
          await _dio.patch(path, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      await _checkConnectivity();
      final response =
          await _dio.delete(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Generic request method with retry logic
  Future<Response> _makeRequest(Future<Response> Function() request) async {
    _retryCount = 0;

    while (_retryCount < maxRetries) {
      try {
        final response = await request();
        _retryCount = 0;
        return response;
      } catch (e) {
        _retryCount++;

        if (_retryCount >= maxRetries) {
          throw _handleError(e);
        }

        // Wait before retyr
        await Future.delayed(Duration(seconds: _retryCount * 2));
      }
    }

    throw UnknownException('Max retries exceeded');
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw NoInternetException('No internet connection');
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException('Request timeout');

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = _getErrorMessage(statusCode);
          return ServerException('$message (Status: $statusCode)');

        case DioExceptionType.cancel:
          return CancelException('Request cancelled');
        default:
          return NetworkException('Network error: ${error.message}');
      }
    }
    return UnknownException('Unknown error occurred: ${error.toString()}');
  }

  String _getErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad Request - Please check your input';
      case 401:
        return 'Unauthorized - Please login again';
      case 403:
        return 'Forbidden - Access denied';
      case 404:
        return 'Not Found - Resource not available';
      case 500:
        return 'Internal Server Error - Please try again later';

      default:
        return 'Server error occurred';
    }
  }
}

// Interceptors
class _AuthInterceptor extends Interceptor {
  final GetStorage _storage = GetStorage();

  // Endpoints that don't require authentication
  final List<String> _noAuthEndpoints = [
    '/api/signin',
    '/api/signup',
    '/api/google-auth',
    '/api/apple-auth',
    '/api/verify-otp',
    '/api/verify-signin',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requiresAuth =
        !_noAuthEndpoints.any((endpoint) => options.path.contains(endpoint));

    if (requiresAuth) {
      final token = _storage.read('auth_token');
      print(
          '🔍 Auth Interceptor - Token: ${token != null ? 'EXISTS' : 'MISSING'}');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        print('🔍 Auth Interceptor - Added Authorization header');
      }
    } else {
      print('🔍 Auth Interceptor - Skipping auth for: ${options.path}');
    }
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('🚀 REQUEST: ${options.method} ${options.path}');
    print('🔝 HEADERS: ${options.headers}');
    if (options.data != null) {
      print('📦 DATA: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');

    // Check if response is HTML instead of JSON
    if (response.data is String &&
        response.data.toString().contains('<!doctype html>')) {
      print(
          '⚠️ WARNING: Server returned HTML instead of JSON. This might indicate a backend configuration issue.');
    }

    print('📱 DATA: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERROR: ${err.message}');
    print('🔍 DETAILS: ${err.response?.data}');
    handler.next(err);
  }
}

class _RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      // Let the main retry login handle this
      handler.next(err);
    } else {
      handler.next(err);
    }
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Show connection error for network issues, don't clear auth
    if (_isNetworkError(err)) {
      _showConnectionAlert();
      handler.next(err);
      return;
    }

    // Only clear auth for genuine 401 errors with server response
    if (err.response?.statusCode == 401 && err.response?.data != null) {
      GetStorage().remove('auth_token');
      GetStorage().remove('user_data');
    }
    handler.next(err);
  }

  bool _isNetworkError(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }

  void _showConnectionAlert() {
    GetX.Get.snackbar(
      "Connection Error",
      "Please check your internet connection and try again",
      snackPosition: GetX.SnackPosition.TOP,
      backgroundColor: KConstColors.errorSnackbar,
      duration: Duration(seconds: 3),
    );
  }
}
