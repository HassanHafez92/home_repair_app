// File: lib/screens/technician/service_areas_screen.dart
// Purpose: Allow technicians to manage their service areas.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/technician_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/map_picker_dialog.dart';

class ServiceAreasScreen extends StatefulWidget {
  const ServiceAreasScreen({super.key});

  @override
  State<ServiceAreasScreen> createState() => _ServiceAreasScreenState();
}

class _ServiceAreasScreenState extends State<ServiceAreasScreen> {
  final _firestoreService = FirestoreService();
  final _areaController = TextEditingController();

  List<String> _serviceAreas = [];
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadServiceAreas();
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _loadServiceAreas() async {
    final user = Provider.of<AuthService>(context, listen: false).currentUser;
    if (user != null) {
      final userData = await _firestoreService.getUser(user.uid);
      if (userData is TechnicianModel && mounted) {
        setState(() {
          _serviceAreas = List.from(userData.serviceAreas);
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAreaFromMap() async {
    final selectedArea = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const MapPickerDialog(),
      ),
    );

    if (selectedArea != null && selectedArea.isNotEmpty && mounted) {
      _areaController.text = selectedArea;
      await _addArea();
    }
  }

  Future<void> _addArea() async {
    final area = _areaController.text.trim();
    if (area.isEmpty) return;

    if (_serviceAreas.contains(area)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('areaAlreadyAdded'.tr())));
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user == null) return;

      final newAreas = [..._serviceAreas, area];
      await _firestoreService.updateUserFields(user.uid, {
        'serviceAreas': newAreas,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _serviceAreas = newAreas;
          _isUpdating = false;
        });
        _areaController.clear();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('areaAdded'.tr())));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errorAddingArea'.tr())));
      }
    }
  }

  Future<void> _removeArea(String area) async {
    setState(() => _isUpdating = true);

    try {
      final user = Provider.of<AuthService>(context, listen: false).currentUser;
      if (user == null) return;

      final newAreas = List<String>.from(_serviceAreas)..remove(area);
      await _firestoreService.updateUserFields(user.uid, {
        'serviceAreas': newAreas,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _serviceAreas = newAreas;
          _isUpdating = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('areaRemoved'.tr())));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errorRemovingArea'.tr())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('serviceAreas'.tr())),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _areaController,
                          label: 'enterArea'.tr(), // e.g. "Zip Code or City"
                          hint: 'areaHint'.tr(),
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _isUpdating ? null : _addArea,
                        icon: _isUpdating
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.add_circle,
                                size: 32,
                                color: Colors.blue,
                              ),
                      ),
                      IconButton(
                        onPressed: _isUpdating ? null : _pickAreaFromMap,
                        icon: const Icon(
                          Icons.map,
                          size: 32,
                          color: Colors.green,
                        ),
                        tooltip: 'pickFromMap'.tr(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _serviceAreas.isEmpty
                      ? Center(
                          child: Text(
                            'noServiceAreas'.tr(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _serviceAreas.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final area = _serviceAreas[index];
                            return ListTile(
                              leading: const Icon(
                                Icons.location_city,
                                color: Colors.blue,
                              ),
                              title: Text(area),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeArea(area),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
