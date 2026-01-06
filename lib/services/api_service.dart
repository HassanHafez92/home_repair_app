/// API Service
///
/// This service provides a unified interface for making API requests,
/// handling errors, caching, and retries.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// API response wrapper
class ApiResponse<T> {
  final T? data;
  final String? error;
  final int? statusCode;
  final bool isSuccess;

  ApiResponse({
    this.data,
    this.error,
    this.statusCode,
    required this.isSuccess,
  });

  factory ApiResponse.success(T data, {int? statusCode}) {
    return ApiResponse<T>(data: data, statusCode: statusCode, isSuccess: true);
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse<T>(
      error: error,
      statusCode: statusCode,
      isSuccess: false,
    );
  }
}

/// API configuration
class ApiConfig {
  static const String baseUrl = 'https://api.example.com';
  static const Duration timeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
}

/// API request method
enum ApiMethod { get, post, put, patch, delete }

/// API service
class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();
  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Make GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      endpoint,
      method: ApiMethod.get,
      headers: headers,
      queryParams: queryParams,
      parser: parser,
    );
  }

  /// Make POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      endpoint,
      method: ApiMethod.post,
      headers: headers,
      body: body,
      parser: parser,
    );
  }

  /// Make PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      endpoint,
      method: ApiMethod.put,
      headers: headers,
      body: body,
      parser: parser,
    );
  }

  /// Make PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      endpoint,
      method: ApiMethod.patch,
      headers: headers,
      body: body,
      parser: parser,
    );
  }

  /// Make DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      endpoint,
      method: ApiMethod.delete,
      headers: headers,
      parser: parser,
    );
  }

  /// Make HTTP request with retry logic
  Future<ApiResponse<T>> _request<T>(
    String endpoint, {
    required ApiMethod method,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    dynamic body,
    T Function(dynamic)? parser,
  }) async {
    int retryCount = 0;
    ApiResponse<T>? lastResponse;

    while (retryCount <= ApiConfig.maxRetries) {
      try {
        final response = await _executeRequest(
          endpoint,
          method: method,
          headers: headers,
          queryParams: queryParams,
          body: body,
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = _parseResponse<T>(response.body, parser);
          return ApiResponse.success(data, statusCode: response.statusCode);
        } else if (response.statusCode == 401) {
          return ApiResponse.error(
            'Unauthorized access',
            statusCode: response.statusCode,
          );
        } else if (response.statusCode == 404) {
          return ApiResponse.error(
            'Resource not found',
            statusCode: response.statusCode,
          );
        } else if (response.statusCode >= 500) {
          lastResponse = ApiResponse.error(
            'Server error',
            statusCode: response.statusCode,
          );
          retryCount++;
          if (retryCount <= ApiConfig.maxRetries) {
            await Future.delayed(ApiConfig.retryDelay);
            continue;
          }
          return lastResponse;
        } else {
          return ApiResponse.error(
            'Request failed with status ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }
      } on TimeoutException {
        lastResponse = ApiResponse.error('Request timeout');
        retryCount++;
        if (retryCount <= ApiConfig.maxRetries) {
          await Future.delayed(ApiConfig.retryDelay);
          continue;
        }
        return lastResponse;
      } on SocketException {
        return ApiResponse.error('Network error');
      } catch (e) {
        debugPrint('API request error: $e');
        return ApiResponse.error('An unexpected error occurred');
      }
    }

    return lastResponse ?? ApiResponse.error('Request failed');
  }

  /// Execute HTTP request
  Future<http.Response> _executeRequest(
    String endpoint, {
    required ApiMethod method,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    dynamic body,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    final mergedHeaders = {..._defaultHeaders, ...?headers};

    http.Response response;
    switch (method) {
      case ApiMethod.get:
        response = await _client
            .get(uri, headers: mergedHeaders)
            .timeout(ApiConfig.timeout);
        break;
      case ApiMethod.post:
        response = await _client
            .post(
              uri,
              headers: mergedHeaders,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(ApiConfig.timeout);
        break;
      case ApiMethod.put:
        response = await _client
            .put(
              uri,
              headers: mergedHeaders,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(ApiConfig.timeout);
        break;
      case ApiMethod.patch:
        response = await _client
            .patch(
              uri,
              headers: mergedHeaders,
              body: body != null ? jsonEncode(body) : null,
            )
            .timeout(ApiConfig.timeout);
        break;
      case ApiMethod.delete:
        response = await _client
            .delete(uri, headers: mergedHeaders)
            .timeout(ApiConfig.timeout);
        break;
    }

    return response;
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParams) {
    final url = endpoint.startsWith('http')
        ? endpoint
        : '${ApiConfig.baseUrl}$endpoint';

    if (queryParams == null || queryParams.isEmpty) {
      return Uri.parse(url);
    }

    return Uri.parse(url).replace(
      queryParameters: queryParams.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  /// Parse response data
  T _parseResponse<T>(String body, T Function(dynamic)? parser) {
    if (body.isEmpty) {
      return null as T;
    }

    try {
      final decoded = jsonDecode(body);
      return parser != null ? parser(decoded) : decoded as T;
    } catch (e) {
      debugPrint('Error parsing response: $e');
      throw FormatException('Failed to parse response');
    }
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _defaultHeaders['Authorization'] = 'Bearer $token';
  }

  /// Clear authentication token
  void clearAuthToken() {
    _defaultHeaders.remove('Authorization');
  }

  /// Set default header
  void setDefaultHeader(String key, String value) {
    _defaultHeaders[key] = value;
  }

  /// Remove default header
  void removeDefaultHeader(String key) {
    _defaultHeaders.remove(key);
  }

  /// Dispose client
  void dispose() {
    _client.close();
  }
}

/// API exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message';
}

/// API cache
class ApiCache {
  final Map<String, _CacheEntry> _cache = {};
  final Duration defaultTtl;

  ApiCache({this.defaultTtl = const Duration(minutes: 5)});

  /// Get cached response
  // ignore: library_private_types_in_public_api
  _CacheEntry? get(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry;
    }
    _cache.remove(key);
    return null;
  }

  /// Set cached response
  void set(String key, dynamic data, {Duration? ttl}) {
    _cache[key] = _CacheEntry(data, DateTime.now().add(ttl ?? defaultTtl));
  }

  /// Clear cache
  void clear() {
    _cache.clear();
  }

  /// Clear expired entries
  void clearExpired() {
    final _ = DateTime.now();
    _cache.removeWhere((key, entry) => entry.isExpired);
  }

  /// Check if key exists
  bool containsKey(String key) {
    final entry = _cache[key];
    return entry != null && !entry.isExpired;
  }
}

/// Cache entry
class _CacheEntry {
  final dynamic data;
  final DateTime expiryTime;

  _CacheEntry(this.data, this.expiryTime);

  bool get isExpired => DateTime.now().isAfter(expiryTime);
  bool isExpiredAt(DateTime time) => time.isAfter(expiryTime);
}
