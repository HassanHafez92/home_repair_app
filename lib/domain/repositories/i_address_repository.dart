/// Repository interface for address operations.
///
/// Defines the contract for saved address data access.
/// Implementations handle Firestore/remote data sources.

import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/address_entity.dart';

abstract class IAddressRepository {
  /// Get all saved addresses for a user.
  Future<Either<Failure, List<AddressEntity>>> getUserAddresses(String userId);

  /// Get a specific address by ID.
  Future<Either<Failure, AddressEntity>> getAddressById(String addressId);

  /// Get the default address for a user.
  Future<Either<Failure, AddressEntity?>> getDefaultAddress(String userId);

  /// Create a new saved address.
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
  });

  /// Update an existing address.
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
  });

  /// Delete an address.
  Future<Either<Failure, void>> deleteAddress(String addressId);

  /// Set an address as default.
  Future<Either<Failure, void>> setDefaultAddress(
    String userId,
    String addressId,
  );

  /// Increment usage count for an address.
  Future<Either<Failure, void>> incrementUsageCount(String addressId);
}
