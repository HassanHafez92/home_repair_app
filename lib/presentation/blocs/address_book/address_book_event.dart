// File: lib/blocs/address_book/address_book_event.dart
// Purpose: Events for address book BLoC

import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class AddressBookEvent extends Equatable {
  const AddressBookEvent();

  @override
  List<Object?> get props => [];
}

/// Load all saved addresses for a user
class LoadAddresses extends AddressBookEvent {
  final String userId;

  const LoadAddresses(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Add a new saved address
class AddAddress extends AddressBookEvent {
  final String userId;
  final String label;
  final String address;
  final LatLng location;
  final bool isDefault;
  final String? street;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? city;

  const AddAddress({
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

  @override
  List<Object?> get props => [
    userId,
    label,
    address,
    location,
    isDefault,
    street,
    building,
    floor,
    apartment,
    city,
  ];
}

/// Update an existing saved address
class UpdateAddress extends AddressBookEvent {
  final String userId;
  final String addressId;
  final String? label;
  final String? address;
  final LatLng? location;
  final bool? isDefault;
  final String? street;
  final String? building;
  final String? floor;
  final String? apartment;
  final String? city;

  const UpdateAddress({
    required this.userId,
    required this.addressId,
    this.label,
    this.address,
    this.location,
    this.isDefault,
    this.street,
    this.building,
    this.floor,
    this.apartment,
    this.city,
  });

  @override
  List<Object?> get props => [
    userId,
    addressId,
    label,
    address,
    location,
    isDefault,
    street,
    building,
    floor,
    apartment,
    city,
  ];
}

/// Delete a saved address
class DeleteAddress extends AddressBookEvent {
  final String userId;
  final String addressId;

  const DeleteAddress({required this.userId, required this.addressId});

  @override
  List<Object?> get props => [userId, addressId];
}

/// Set an address as default
class SetDefaultAddress extends AddressBookEvent {
  final String userId;
  final String addressId;

  const SetDefaultAddress({required this.userId, required this.addressId});

  @override
  List<Object?> get props => [userId, addressId];
}

/// Record address usage
class RecordAddressUsage extends AddressBookEvent {
  final String userId;
  final String addressId;

  const RecordAddressUsage({required this.userId, required this.addressId});

  @override
  List<Object?> get props => [userId, addressId];
}



