/// Exception classes for data layer errors.
library exceptions;

/// Base exception for server errors.
class ServerException implements Exception {
  final String message;
  final String? code;

  const ServerException([this.message = 'Server error', this.code]);

  @override
  String toString() => 'ServerException: $message';
}

/// Exception for authentication errors.
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException([this.message = 'Auth error', this.code]);

  @override
  String toString() => 'AuthException: $message';
}

/// Exception for cache errors.
class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache error']);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception when a resource is not found.
class NotFoundException implements Exception {
  final String message;

  const NotFoundException([this.message = 'Not found']);

  @override
  String toString() => 'NotFoundException: $message';
}
