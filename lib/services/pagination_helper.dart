// File: lib/services/pagination_helper.dart
// Purpose: Helper utilities for pagination in Firestore queries

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/paginated_result.dart';

/// Helper class for implementing pagination with Firestore
class PaginationHelper {
  /// Private constructor
  PaginationHelper._();

  /// Create paginated query with cursor-based pagination
  static Query<T> paginateQuery<T>(
    Query<T> query, {
    required int pageSize,
    String? cursor,
  }) {
    var paginatedQuery = query.limit(pageSize + 1);

    if (cursor != null && cursor.isNotEmpty) {
      // In a real app, you'd fetch the document at cursor position
      // and use startAfterDocument for proper pagination
      paginatedQuery = paginatedQuery.startAt([cursor]);
    }

    return paginatedQuery;
  }

  /// Convert Firestore query snapshot to paginated result
  static PaginatedResult<T> createPaginatedResult<T>({
    required List<QueryDocumentSnapshot<T>> documents,
    required int pageSize,
    required T Function(Map<String, dynamic>, String id) fromJson,
  }) {
    final hasMore = documents.length > pageSize;
    final items = documents.take(pageSize).map((doc) {
      final data = doc.data();
      if (data is Map<String, dynamic>) {
        return fromJson(data, doc.id);
      }
      return data;
    }).toList();

    final nextCursor = hasMore && documents.length > pageSize
        ? documents[pageSize].id
        : null;

    return PaginatedResult<T>(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }

  static PaginatedResult<T> createOffsetPaginatedResult<T>({
    required List<T> allItems,
    required int pageNumber,
    required int pageSize,
  }) {
    final startIndex = (pageNumber - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    final total = allItems.length;
    final totalPages = (total / pageSize).ceil();

    final items = allItems.sublist(
      startIndex,
      endIndex > allItems.length ? allItems.length : endIndex,
    );

    return PaginatedResult<T>(
      items: items,
      hasMore: endIndex < total,
      currentPage: pageNumber,
      totalPages: totalPages,
      total: total,
    );
  }

  /// Check if query needs pagination
  static bool needsPagination(int itemCount, int pageSize) {
    return itemCount >= pageSize;
  }
}
