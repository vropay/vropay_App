class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message';
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message, [super.statusCode]);
}

class TimeoutException extends ApiException {
  TimeoutException(super.message);
}

class NoInternetException extends ApiException {
  NoInternetException(super.message);
}

class CancelException extends ApiException {
  CancelException(super.message);
}

class UnknownException extends ApiException {
  UnknownException(super.message);
}
