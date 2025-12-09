// File: lib/blocs/address_book/address_book_state.dart
// Purpose: State for address book BLoC

import 'package:equatable/equatable.dart';
import 'package:home_repair_app/models/saved_address.dart';

enum AddressBookStatus { initial, loading, success, failure }

class AddressBookState extends Equatable {
  final AddressBookStatus status;
  final List<SavedAddress> addresses;
  final String? errorMessage;

  const AddressBookState({
    this.status = AddressBookStatus.initial,
    this.addresses = const [],
    this.errorMessage,
  });

  AddressBookState copyWith({
    AddressBookStatus? status,
    List<SavedAddress>? addresses,
    String? errorMessage,
  }) {
    return AddressBookState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, addresses, errorMessage];
}



