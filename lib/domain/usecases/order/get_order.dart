// Get order use case.

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/order_entity.dart';
import '../../repositories/i_order_repository.dart';

/// Use case for getting an order by ID.
class GetOrder implements UseCase<OrderEntity?, GetOrderParams> {
  final IOrderRepository repository;

  GetOrder(this.repository);

  @override
  Future<Either<Failure, OrderEntity?>> call(GetOrderParams params) {
    return repository.getOrder(params.orderId);
  }
}

/// Parameters for getting an order.
class GetOrderParams {
  final String orderId;

  const GetOrderParams({required this.orderId});
}
