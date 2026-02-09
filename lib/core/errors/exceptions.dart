/// Custom exceptions for the app
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error occurred']);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network error occurred']);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error occurred']);

  @override
  String toString() => message;
}

class ValidationException implements Exception {
  final String message;
  ValidationException([this.message = 'Validation error occurred']);

  @override
  String toString() => message;
}

class PermissionException implements Exception {
  final String message;
  PermissionException([this.message = 'Permission denied']);

  @override
  String toString() => message;
}
