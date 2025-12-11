// Update order status use case.

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/order_entity.dart';
import '../../repositories/i_order_repository.dart';

/// Use case for updating order status.
class UpdateOrderStatus implements UseCase<void, UpdateOrderStatusParams> {
  final IOrderRepository repository;

  UpdateOrderStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateOrderStatusParams params) {
    return repository.updateOrderStatus(params.orderId, params.status);
  }
}

/// Parameters for updating order status.
class UpdateOrderStatusParams {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatusParams({required this.orderId, required this.status});
}
