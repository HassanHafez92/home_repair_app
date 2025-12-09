/// Create order use case.

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/order_entity.dart';
import '../../repositories/i_order_repository.dart';

/// Use case for creating a new order.
class CreateOrder implements UseCase<String, CreateOrderParams> {
  final IOrderRepository repository;

  CreateOrder(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateOrderParams params) {
    return repository.createOrder(params.order);
  }
}

/// Parameters for creating an order.
class CreateOrderParams {
  final OrderEntity order;

  const CreateOrderParams({required this.order});
}
