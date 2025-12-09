/// Complete order use case.

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/i_order_repository.dart';

/// Use case for completing an order.
class CompleteOrder implements UseCase<void, CompleteOrderParams> {
  final IOrderRepository repository;

  CompleteOrder(this.repository);

  @override
  Future<Either<Failure, void>> call(CompleteOrderParams params) {
    return repository.completeOrder(
      params.orderId,
      params.finalPrice,
      params.notes,
    );
  }
}

/// Parameters for completing an order.
class CompleteOrderParams {
  final String orderId;
  final double finalPrice;
  final String? notes;

  const CompleteOrderParams({
    required this.orderId,
    required this.finalPrice,
    this.notes,
  });
}
