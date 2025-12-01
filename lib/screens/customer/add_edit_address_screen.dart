// File: lib/screens/customer/add_edit_address_screen.dart
// Purpose: Screen for adding or editing a saved address

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../blocs/address_book/address_book_bloc.dart';
import '../../blocs/address_book/address_book_event.dart';
import '../../models/saved_address.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/map_utils.dart';
import '../../widgets/map_location_picker.dart';

class AddEditAddressScreen extends StatefulWidget {
  final String userId;
  final SavedAddress? address;

  const AddEditAddressScreen({super.key, required this.userId, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _addressController;
  late TextEditingController _streetController;
  late TextEditingController _buildingController;
  late TextEditingController _floorController;
  late TextEditingController _apartmentController;
  late TextEditingController _cityController;

  LatLng? _selectedLocation;
  String _selectedLabel = 'Home';
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _labelController = TextEditingController(text: address?.label);
    _addressController = TextEditingController(text: address?.address);
    _streetController = TextEditingController(text: address?.street);
    _buildingController = TextEditingController(text: address?.building);
    _floorController = TextEditingController(text: address?.floor);
    _apartmentController = TextEditingController(text: address?.apartment);
    _cityController = TextEditingController(text: address?.city);

    if (address != null) {
      _selectedLocation = MapUtils.geoPointToLatLng(address.location);
      _selectedLabel = address.label;
      _isDefault = address.isDefault;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _onLocationSelected(LatLng location, String address) {
    setState(() {
      _selectedLocation = location;
      _addressController.text = address;

      // Try to parse components if possible, or just leave them for user to fill
      // In a real app, we might parse the address components from geocoding result
    });
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      if (_selectedLocation == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('pleaseSelectLocation'.tr())));
        return;
      }

      if (widget.address != null) {
        // Update existing
        context.read<AddressBookBloc>().add(
          UpdateAddress(
            userId: widget.userId,
            addressId: widget.address!.id,
            label: _selectedLabel,
            address: _addressController.text,
            location: _selectedLocation,
            isDefault: _isDefault,
            street: _streetController.text,
            building: _buildingController.text,
            floor: _floorController.text,
            apartment: _apartmentController.text,
            city: _cityController.text,
          ),
        );
      } else {
        // Add new
        context.read<AddressBookBloc>().add(
          AddAddress(
            userId: widget.userId,
            label: _selectedLabel,
            address: _addressController.text,
            location: _selectedLocation!,
            isDefault: _isDefault,
            street: _streetController.text,
            building: _buildingController.text,
            floor: _floorController.text,
            apartment: _apartmentController.text,
            city: _cityController.text,
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'editAddress'.tr() : 'addNewAddress'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map Preview / Selector
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapLocationPicker(
                        initialLocation: _selectedLocation,
                        onLocationSelected: _onLocationSelected,
                      ),
                    ),
                  );
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _selectedLocation != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              // Placeholder for static map or just a marker icon
                              Center(
                                child: Icon(
                                  Icons.location_on,
                                  size: 40,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.edit, size: 14),
                                      const SizedBox(width: 4),
                                      Text('changeLocation'.tr()),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.map, size: 40, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text('tapToSelectLocation'.tr()),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Label Selection
              Text(
                'addressLabel'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildLabelChip('Home'),
                  const SizedBox(width: 8),
                  _buildLabelChip('Work'),
                  const SizedBox(width: 8),
                  _buildLabelChip('Other'),
                ],
              ),
              if (_selectedLabel == 'Other') ...[
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _labelController,
                  label: 'customLabel'.tr(),
                  hint: 'enterCustomLabel'.tr(),
                  onChanged: (value) => _selectedLabel = value,
                ),
              ],
              const SizedBox(height: 16),

              // Address Details
              CustomTextField(
                controller: _addressController,
                label: 'fullAddress'.tr(),
                hint: 'enterFullAddress'.tr(),
                maxLines: 2,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'requiredField'.tr() : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      label: 'city'.tr(),
                      hint: 'enterCity'.tr(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _streetController,
                      label: 'street'.tr(),
                      hint: 'enterStreet'.tr(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _buildingController,
                      label: 'building'.tr(),
                      hint: 'buildingNumber'.tr(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _floorController,
                      label: 'floor'.tr(),
                      hint: 'floorNumber'.tr(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _apartmentController,
                label: 'apartment'.tr(),
                hint: 'apartmentNumber'.tr(),
              ),
              const SizedBox(height: 24),

              // Default Checkbox
              CheckboxListTile(
                value: _isDefault,
                onChanged: (value) {
                  setState(() => _isDefault = value ?? false);
                },
                title: Text('setAsDefaultAddress'.tr()),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: isEditing ? 'saveChanges'.tr() : 'saveAddress'.tr(),
                onPressed: _saveAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabelChip(String label) {
    final isSelected = _selectedLabel == label;
    return ChoiceChip(
      label: Text(label.tr()),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedLabel = label);
        }
      },
    );
  }
}
