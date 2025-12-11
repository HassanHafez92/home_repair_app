// Implementation of INotificationRepository using FirestoreService as data source.
//
// Wraps the existing FirestoreService notification methods and returns Either types.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/i_notification_repository.dart';
import '../../services/firestore_service.dart';
import '../../models/notification_model.dart' as model;

class NotificationRepositoryImpl implements INotificationRepository {
  final FirestoreService _firestoreService;
  final FirebaseFirestore _db;

  NotificationRepositoryImpl({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService(),
      _db = FirebaseFirestore.instance;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getUserNotifications(
    String userId,
  ) async {
    try {
      // Get first emission from the stream
      final notifications = await _firestoreService
          .getUserNotifications(userId)
          .first;
      return Right(notifications.map(_mapNotificationModelToEntity).toList());
    } catch (e) {
      return Left(ServerFailure('Failed to get user notifications: $e'));
    }
  }

  @override
  Stream<List<NotificationEntity>> streamUserNotifications(String userId) {
    return _firestoreService
        .getUserNotifications(userId)
        .map(
          (notifications) =>
              notifications.map(_mapNotificationModelToEntity).toList(),
        );
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _firestoreService.markNotificationAsRead(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to mark notification as read: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    try {
      // Get all unread notifications for user and mark them as read
      final snapshot = await _db
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      return const Right(null);
    } catch (e) {
      return Left(
        ServerFailure('Failed to mark all notifications as read: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
    String notificationId,
  ) async {
    try {
      await _db.collection('notifications').doc(notificationId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete notification: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount(String userId) async {
    try {
      final snapshot = await _db
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return Right(snapshot.count ?? 0);
    } catch (e) {
      return Left(ServerFailure('Failed to get unread count: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationId = const Uuid().v4();
      final now = DateTime.now();

      final notificationData = {
        'id': notificationId,
        'userId': userId,
        'type': type.name,
        'title': title,
        'message': message,
        'data': data,
        'isRead': false,
        'timestamp': Timestamp.fromDate(now),
      };

      await _db
          .collection('notifications')
          .doc(notificationId)
          .set(notificationData);

      return Right(
        NotificationEntity(
          id: notificationId,
          userId: userId,
          type: type,
          title: title,
          message: message,
          data: data,
          isRead: false,
          timestamp: now,
        ),
      );
    } catch (e) {
      return Left(ServerFailure('Failed to create notification: $e'));
    }
  }

  // Helper method for mapping
  NotificationEntity _mapNotificationModelToEntity(
    model.NotificationModel notif,
  ) {
    return NotificationEntity(
      id: notif.id,
      userId: notif.userId,
      type: _mapNotificationType(notif.type),
      title: notif.title,
      message: notif.message,
      data: notif.data,
      isRead: notif.isRead,
      timestamp: notif.timestamp,
    );
  }

  NotificationType _mapNotificationType(dynamic modelType) {
    switch (modelType.toString()) {
      case 'NotificationType.order':
        return NotificationType.order;
      case 'NotificationType.payment':
        return NotificationType.payment;
      case 'NotificationType.offer':
        return NotificationType.offer;
      case 'NotificationType.system':
      default:
        return NotificationType.system;
    }
  }
}
