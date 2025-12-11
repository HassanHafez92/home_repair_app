// Application configuration constants.
//
// Centralized location for all configuration values including
// cache durations, timeouts, pagination settings, and Firestore collection names.

// Cache configuration constants.
class CacheConstants {
  CacheConstants._();

  /// Duration before cached data is considered stale.
  static const Duration cacheTtl = Duration(hours: 24);

  /// Duration for short-lived cache (e.g., search results).
  static const Duration shortCacheTtl = Duration(minutes: 30);

  /// Maximum number of items to cache per collection.
  static const int maxCacheItems = 500;

  /// Cache key prefixes
  static const String userCacheKey = 'cached_user';
  static const String servicesCacheKey = 'cached_services';
  static const String ordersCacheKey = 'cached_orders';
}

/// Network and API configuration constants.
class NetworkConstants {
  NetworkConstants._();

  /// Default timeout for network requests.
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Timeout for long-running operations.
  static const Duration longRequestTimeout = Duration(minutes: 2);

  /// Number of retries for failed network requests.
  static const int maxRetries = 3;

  /// Delay between retry attempts (increases exponentially).
  static const Duration retryDelay = Duration(seconds: 2);
}

/// Pagination configuration constants.
class PaginationConstants {
  PaginationConstants._();

  /// Default page size for list queries.
  static const int defaultPageSize = 20;

  /// Maximum page size allowed.
  static const int maxPageSize = 100;
}

/// Firestore collection name constants.
class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String technicians = 'technicians';
  static const String customers = 'customers';
  static const String services = 'services';
  static const String categories = 'categories';
  static const String orders = 'orders';
  static const String reviews = 'reviews';
  static const String chats = 'chats';
  static const String messages = 'messages';
  static const String notifications = 'notifications';
  static const String addresses = 'addresses';
  static const String payments = 'payments';
  static const String promotions = 'promotions';
  static const String supportChats = 'supportChats';
}

/// Validation constants.
class ValidationConstants {
  ValidationConstants._();

  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int maxBioLength = 500;
  static const int maxReviewLength = 1000;
}
