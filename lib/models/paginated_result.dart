// File: lib/models/paginated_result.dart
// Purpose: Generic pagination model for list responses

import 'package:equatable/equatable.dart';

/// Generic pagination wrapper for list responses
class PaginatedResult<T> extends Equatable {
  /// The items on the current page
  final List<T> items;

  /// Whether there are more items to load
  final bool hasMore;

  /// Cursor/token for fetching the next page
  final String? nextCursor;

  /// Total number of items (if available)
  final int? total;

  /// Current page number (if using offset-based pagination)
  final int? currentPage;

  /// Total number of pages (if available)
  final int? totalPages;

  const PaginatedResult({
    required this.items,
    required this.hasMore,
    this.nextCursor,
    this.total,
    this.currentPage,
    this.totalPages,
  });

  /// Create a copy with updated fields
  PaginatedResult<T> copyWith({
    List<T>? items,
    bool? hasMore,
    String? nextCursor,
    int? total,
    int? currentPage,
    int? totalPages,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  /// Add more items to the current result
  PaginatedResult<T> addItems(List<T> newItems) {
    return copyWith(items: [...items, ...newItems]);
  }

  /// Check if this is the last page
  bool get isLastPage => !hasMore;

  /// Get the number of items on the current page
  int get itemCount => items.length;

  /// Check if there are any items
  bool get isEmpty => items.isEmpty;

  /// Check if there are items
  bool get isNotEmpty => items.isNotEmpty;

  @override
  List<Object?> get props => [
    items,
    hasMore,
    nextCursor,
    total,
    currentPage,
    totalPages,
  ];
}
