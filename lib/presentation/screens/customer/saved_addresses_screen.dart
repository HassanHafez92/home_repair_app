// File: lib/screens/customer/saved_addresses_screen.dart
// Purpose: Manage saved addresses with add, edit, delete, and set default functionality using BLoC.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../blocs/address_book/address_book_bloc.dart';
import '../../blocs/address_book/address_book_event.dart';
import '../../blocs/address_book/address_book_state.dart';
import 'package:home_repair_app/models/saved_address.dart';
import 'package:home_repair_app/services/auth_service.dart';
import 'add_edit_address_screen.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    if (user != null) {
      _userId = user.uid;
      context.read<AddressBookBloc>().add(LoadAddresses(_userId!));
    }
  }

  void _deleteAddress(SavedAddress address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deleteAddress'.tr()),
        content: Text('deleteAddressConfirmation'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              if (_userId != null) {
                context.read<AddressBookBloc>().add(
                  DeleteAddress(userId: _userId!, addressId: address.id),
                );
              }
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );
  }

  void _setDefaultAddress(SavedAddress address) {
    if (_userId != null) {
      context.read<AddressBookBloc>().add(
        SetDefaultAddress(userId: _userId!, addressId: address.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('savedAddresses'.tr())),
      body: BlocBuilder<AddressBookBloc, AddressBookState>(
        builder: (context, state) {
          if (state.status == AddressBookStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AddressBookStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('errorLoadingAddresses'.tr()),
                  TextButton(
                    onPressed: _loadAddresses,
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          if (state.addresses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_off_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'noAddressesSaved'.tr(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.addresses.length,
            itemBuilder: (context, index) {
              final address = state.addresses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getIconForLabel(address.label),
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            address.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'default'.tr(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          PopupMenuButton<String>(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('edit'.tr()),
                              ),
                              if (!address.isDefault)
                                PopupMenuItem(
                                  value: 'default',
                                  child: Text('setAsDefault'.tr()),
                                ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'delete'.tr(),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEditAddressScreen(
                                      userId: _userId!,
                                      address: address,
                                    ),
                                  ),
                                );
                              } else if (value == 'default') {
                                _setDefaultAddress(address);
                              } else if (value == 'delete') {
                                _deleteAddress(address);
                              }
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      Text(address.address),
                      if (address.city != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          address.city!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddEditAddressScreen(userId: _userId!),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }
}



