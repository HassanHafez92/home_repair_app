// Use case for deleting an address.

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/i_address_repository.dart';

class DeleteAddress implements UseCase<void, String> {
  final IAddressRepository repository;

  DeleteAddress(this.repository);

  @override
  Future<Either<Failure, void>> call(String addressId) async {
    return repository.deleteAddress(addressId);
  }
}
