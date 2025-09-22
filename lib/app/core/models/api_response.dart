class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse(
      {required this.success,
      required this.message,
      this.data,
      this.statusCode,
      this.errors});

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ??
          (json['statusCode'] == 200 || json['statusCode'] == 201),
      message: json['message'] ?? json['error'] ?? 'Unknown error',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      statusCode: json['statusCode'],
      errors: json['errors'],
    );
  }

  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: 200,
    );
  }

  factory ApiResponse.error(String message,
      {int? statusCode, Map<String, dynamic>? errors}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }
}
