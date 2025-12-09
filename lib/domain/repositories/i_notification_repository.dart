/// Repository interface for notification operations.
///
/// Defines the contract for notification-related data access.
/// Implementations handle Firestore/remote data sources.

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/notification_entity.dart';

abstract class INotificationRepository {
  /// Get notifications for a user.
  Future<Either<Failure, List<NotificationEntity>>> getUserNotifications(
    String userId,
  );

  /// Stream notifications for a user.
  Stream<List<NotificationEntity>> streamUserNotifications(String userId);

  /// Mark notification as read.
  Future<Either<Failure, void>> markAsRead(String notificationId);

  /// Mark all notifications as read for a user.
  Future<Either<Failure, void>> markAllAsRead(String userId);

  /// Delete a notification.
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Get unread notification count for a user.
  Future<Either<Failure, int>> getUnreadCount(String userId);

  /// Create a notification (typically called from backend/firebase functions).
  Future<Either<Failure, NotificationEntity>> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  });
}
