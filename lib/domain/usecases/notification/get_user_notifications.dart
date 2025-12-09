/// Use case for getting user notifications.

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/notification_entity.dart';
import '../../repositories/i_notification_repository.dart';

class GetUserNotifications
    implements UseCase<List<NotificationEntity>, String> {
  final INotificationRepository repository;

  GetUserNotifications(this.repository);

  @override
  Future<Either<Failure, List<NotificationEntity>>> call(String userId) async {
    return repository.getUserNotifications(userId);
  }
}
