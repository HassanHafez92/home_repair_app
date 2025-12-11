// Use case for getting user addresses.

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/address_entity.dart';
import '../../repositories/i_address_repository.dart';

class GetUserAddresses implements UseCase<List<AddressEntity>, String> {
  final IAddressRepository repository;

  GetUserAddresses(this.repository);

  @override
  Future<Either<Failure, List<AddressEntity>>> call(String userId) async {
    return repository.getUserAddresses(userId);
  }
}
