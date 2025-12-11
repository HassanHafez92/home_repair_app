// Get services use case.

import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/service_entity.dart';
import '../../repositories/i_service_repository.dart';

/// Use case for getting all services with cache.
class GetServices implements UseCase<List<ServiceEntity>, GetServicesParams> {
  final IServiceRepository repository;

  GetServices(this.repository);

  @override
  Future<Either<Failure, List<ServiceEntity>>> call(GetServicesParams params) {
    return repository.getServicesWithCache(forceRefresh: params.forceRefresh);
  }
}

/// Parameters for getting services.
class GetServicesParams {
  final bool forceRefresh;

  const GetServicesParams({this.forceRefresh = false});
}
