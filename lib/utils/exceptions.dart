// File: lib/utils/exceptions.dart
// Purpose: Custom exception hierarchy for consistent error handling

/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException(this.message, {this.code, this.originalError, this.stackTrace});

  @override
  String toString() => message;
}

/// Thrown when network operations fail
class NetworkException extends AppException {
  NetworkException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Thrown when authentication fails
class AuthException extends AppException {
  AuthException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Thrown when database operations fail
class FirestoreException extends AppException {
  FirestoreException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Thrown when storage operations fail
class StorageException extends AppException {
  StorageException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Thrown when input validation fails
class ValidationException extends AppException {
  final Map<String, String> errors;

  ValidationException(
    super.message, {
    this.errors = const {},
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Thrown when resource is not found
class NotFoundException extends AppException {
  NotFoundException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Thrown when operation is not permitted
class PermissionException extends AppException {
  PermissionException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Thrown when request times out
class TimeoutException extends AppException {
  TimeoutException(
    super.message, {
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Thrown for generic server errors
class ServerException extends AppException {
  final int? statusCode;

  ServerException(
    super.message, {
    this.statusCode,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}
