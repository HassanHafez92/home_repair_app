/// Use case for saving a new address.

import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/address_entity.dart';
import '../../repositories/i_address_repository.dart';

class SaveAddress implements UseCase<AddressEntity, SaveAddressParams> {
  final IAddressRepository repository;

  SaveAddress(this.repository);

  @override
  Future<Either<Failure, AddressEntity>> call(SaveAddressParams params) async {
    return repository.createAddress(
      userId: params.userId,
      label: params.label,
      address: params.address,
      location: params.location,
      isDefault: params.isDefault,
      street: params.street,
      building: params.building,
      floor: params.floor,
      apartment: params.apartment,
      city: params.city,
    );
  }
}

class SaveAddressParams {
  final String userId;
  final String label;
  final String address;
  final Map<String, dynamic> location;
  final bool isDefault;
  final String? street;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? city;

  const SaveAddressParams({
    required this.userId,
    required this.label,
    required this.address,
    required this.location,
    this.isDefault = false,
    this.street,
    this.building,
    this.floor,
    this.apartment,
    this.city,
  });
}
