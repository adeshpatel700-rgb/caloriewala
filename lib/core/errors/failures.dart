import 'package:equatable/equatable.dart';

/// Base class for all failures in the app
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error occurred'])
      : super(message);
}

/// API-related failures
class ApiFailure extends Failure {
  const ApiFailure([String message = 'API error occurred']) : super(message);
}

/// Rate limit exceeded
class RateLimitFailure extends Failure {
  const RateLimitFailure([
    String message = 'Daily limit reached. Please try again tomorrow.',
  ]) : super(message);
}

/// Invalid API key
class AuthenticationFailure extends Failure {
  const AuthenticationFailure([
    String message = 'Invalid API key. Please check your configuration.',
  ]) : super(message);
}

/// Local storage failures
class StorageFailure extends Failure {
  const StorageFailure([String message = 'Storage error occurred'])
      : super(message);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation error occurred'])
      : super(message);
}

/// Image processing failures
class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure([
    String message = 'Failed to process image',
  ]) : super(message);
}

/// Permission denied failures
class PermissionFailure extends Failure {
  const PermissionFailure([
    String message = 'Permission denied',
  ]) : super(message);
}

/// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure([
    String message = 'An unexpected error occurred',
  ]) : super(message);
}
