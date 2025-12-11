// Use case for marking a notification as read.

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/i_notification_repository.dart';

class MarkNotificationAsRead implements UseCase<void, String> {
  final INotificationRepository repository;

  MarkNotificationAsRead(this.repository);

  @override
  Future<Either<Failure, void>> call(String notificationId) async {
    return repository.markAsRead(notificationId);
  }
}
