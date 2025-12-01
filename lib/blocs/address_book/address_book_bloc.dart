// File: lib/blocs/address_book/address_book_bloc.dart
// Purpose: BLoC for managing user's saved addresses

import 'package:flutter_bloc/flutter_bloc.dart';
import 'address_book_event.dart';
import 'address_book_state.dart';
import '../../services/address_service.dart';

class AddressBookBloc extends Bloc<AddressBookEvent, AddressBookState> {
  final AddressService _addressService;

  AddressBookBloc({required AddressService addressService})
    : _addressService = addressService,
      super(const AddressBookState()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<AddAddress>(_onAddAddress);
    on<UpdateAddress>(_onUpdateAddress);
    on<DeleteAddress>(_onDeleteAddress);
    on<SetDefaultAddress>(_onSetDefaultAddress);
    on<RecordAddressUsage>(_onRecordAddressUsage);
  }

  Future<void> _onLoadAddresses(
    LoadAddresses event,
    Emitter<AddressBookState> emit,
  ) async {
    emit(state.copyWith(status: AddressBookStatus.loading));

    try {
      final addresses = await _addressService.getUserAddresses(event.userId);
      emit(
        state.copyWith(status: AddressBookStatus.success, addresses: addresses),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AddressBookStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddAddress(
    AddAddress event,
    Emitter<AddressBookState> emit,
  ) async {
    try {
      await _addressService.saveAddress(
        userId: event.userId,
        label: event.label,
        address: event.address,
        location: event.location,
        isDefault: event.isDefault,
        street: event.street,
        building: event.building,
        floor: event.floor,
        apartment: event.apartment,
        city: event.city,
      );

      // Reload addresses
      add(LoadAddresses(event.userId));
    } catch (e) {
      emit(
        state.copyWith(
          status: AddressBookStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateAddress(
    UpdateAddress event,
    Emitter<AddressBookState> emit,
  ) async {
    try {
      await _addressService.updateAddress(
        userId: event.userId,
        addressId: event.addressId,
        label: event.label,
        address: event.address,
        location: event.location,
        isDefault: event.isDefault,
        street: event.street,
        building: event.building,
        floor: event.floor,
        apartment: event.apartment,
        city: event.city,
      );

      // Reload addresses
      add(LoadAddresses(event.userId));
    } catch (e) {
      emit(
        state.copyWith(
          status: AddressBookStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteAddress(
    DeleteAddress event,
    Emitter<AddressBookState> emit,
  ) async {
    try {
      await _addressService.deleteAddress(event.userId, event.addressId);

      // Reload addresses
      add(LoadAddresses(event.userId));
    } catch (e) {
      emit(
        state.copyWith(
          status: AddressBookStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSetDefaultAddress(
    SetDefaultAddress event,
    Emitter<AddressBookState> emit,
  ) async {
    try {
      await _addressService.setAsDefault(event.userId, event.addressId);

      // Reload addresses
      add(LoadAddresses(event.userId));
    } catch (e) {
      emit(
        state.copyWith(
          status: AddressBookStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRecordAddressUsage(
    RecordAddressUsage event,
    Emitter<AddressBookState> emit,
  ) async {
    try {
      await _addressService.incrementUsage(event.userId, event.addressId);

      // Optionally reload to update usage count
      add(LoadAddresses(event.userId));
    } catch (e) {
      // Silently fail for usage tracking
    }
  }
}
