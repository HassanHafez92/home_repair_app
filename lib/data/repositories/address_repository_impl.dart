// Implementation of IAddressRepository using AddressService as data source.
//
// Wraps the existing AddressService and returns Either types for error handling.

import 'package:dartz/dartz.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/i_address_repository.dart';
import '../../services/address_service.dart';
import '../../models/saved_address.dart';

class AddressRepositoryImpl implements IAddressRepository {
  final AddressService _addressService;

  AddressRepositoryImpl({AddressService? addressService})
    : _addressService = addressService ?? AddressService();

  @override
  Future<Either<Failure, List<AddressEntity>>> getUserAddresses(
    String userId,
  ) async {
    try {
      final addresses = await _addressService.getUserAddresses(userId);
      return Right(addresses.map(_mapSavedAddressToEntity).toList());
    } catch (e) {
      return Left(ServerFailure('Failed to get user addresses: $e'));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> getAddressById(
    String addressId,
  ) async {
    // AddressService doesn't have this method - would need to implement
    return const Left(ServerFailure('getAddressById not yet implemented'));
  }

  @override
  Future<Either<Failure, AddressEntity?>> getDefaultAddress(
    String userId,
  ) async {
    try {
      final address = await _addressService.getDefaultAddress(userId);
      if (address == null) return const Right(null);
      return Right(_mapSavedAddressToEntity(address));
    } catch (e) {
      return Left(ServerFailure('Failed to get default address: $e'));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> createAddress({
    required String userId,
    required String label,
    required String address,
    required Map<String, dynamic> location,
    bool isDefault = false,
    String? street,
    String? building,
    String? floor,
    String? apartment,
    String? city,
  }) async {
    try {
      // Convert location map to LatLng
      final latLng = LatLng(
        (location['latitude'] as num).toDouble(),
        (location['longitude'] as num).toDouble(),
      );

      final savedAddress = await _addressService.saveAddress(
        userId: userId,
        label: label,
        address: address,
        location: latLng,
        isDefault: isDefault,
        street: street,
        building: building,
        floor: floor,
        apartment: apartment,
        city: city,
      );

      return Right(_mapSavedAddressToEntity(savedAddress));
    } catch (e) {
      return Left(ServerFailure('Failed to create address: $e'));
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> updateAddress({
    required String addressId,
    String? label,
    String? address,
    Map<String, dynamic>? location,
    bool? isDefault,
    String? street,
    String? building,
    String? floor,
    String? apartment,
    String? city,
  }) async {
    // AddressService needs userId, but we only have addressId
    // This would need a refactor to work correctly
    return const Left(
      ServerFailure('updateAddress requires userId - needs refactoring'),
    );
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String addressId) async {
    // AddressService needs userId, but we only have addressId
    // This would need a refactor to work correctly
    return const Left(
      ServerFailure('deleteAddress requires userId - needs refactoring'),
    );
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(
    String userId,
    String addressId,
  ) async {
    try {
      await _addressService.setAsDefault(userId, addressId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to set default address: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementUsageCount(String addressId) async {
    // AddressService needs userId - this would need a refactor
    return const Left(
      ServerFailure('incrementUsageCount requires userId - needs refactoring'),
    );
  }

  // Helper method for mapping
  AddressEntity _mapSavedAddressToEntity(SavedAddress model) {
    return AddressEntity(
      id: model.id,
      userId: model.userId,
      label: model.label,
      address: model.address,
      location: Map<String, dynamic>.from(model.location),
      isDefault: model.isDefault,
      street: model.street,
      building: model.building,
      floor: model.floor,
      apartment: model.apartment,
      city: model.city,
      usageCount: model.usageCount,
      lastUsed: model.lastUsed,
      createdAt: model.createdAt,
    );
  }
}
