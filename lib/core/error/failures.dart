// Base failure classes for error handling in Clean Architecture.

// Abstract base class for all application failures.
//
// Failures represent expected error conditions that the application
// can handle gracefully. They are returned as the Left side of an Either type.
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (code: $code)' : ''}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Failure for server/network related errors.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred', super.code]);
}

/// Failure for authentication related errors.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed', super.code]);
}

/// Failure for cache/local storage errors.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred', super.code]);
}

/// Failure for validation errors.
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed', super.code]);
}

/// Failure when a resource is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found', super.code]);
}

/// Failure for permission/authorization errors.
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied', super.code]);
}

/// Failure for network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection', super.code]);
}

/// Failure for database/Firestore operations.
class DatabaseFailure extends Failure {
  const DatabaseFailure([
    super.message = 'Database error occurred',
    super.code,
  ]);
}

/// Failure for operation timeout.
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Operation timed out', super.code]);
}

/// Failure for unexpected/unknown errors.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'An unexpected error occurred',
    super.code,
  ]);
}
