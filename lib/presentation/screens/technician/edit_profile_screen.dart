// File: lib/screens/technician/edit_profile_screen.dart
// Purpose: Allow technicians to edit their profile details.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_repair_app/services/auth_service.dart';
import 'package:home_repair_app/services/firestore_service.dart';
import 'package:home_repair_app/models/technician_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:home_repair_app/utils/image_compression_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController
  _bioController; // Not in model yet, but good to have UI
  late TextEditingController _hourlyRateController;
  late TextEditingController _experienceController;

  bool _isLoading = false;
  String? _profilePhotoUrl;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    // Cast to TechnicianModel if possible, or just use UserModel fields
    // Since we are in Technician flow, we expect it to be TechnicianModel eventually
    // But AuthService might return UserModel. We need to fetch full technician data if needed.
    // For now, let's assume we can get basic info.

    _nameController = TextEditingController(text: user?.displayName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _bioController = TextEditingController(); // Placeholder
    _hourlyRateController = TextEditingController();
    _experienceController = TextEditingController();

    _loadTechnicianData();
  }

  Future<void> _loadTechnicianData() async {
    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      final userData = await _firestoreService.getUser(user.uid);
      if (userData is TechnicianModel && mounted) {
        setState(() {
          _hourlyRateController.text = userData.hourlyRate?.toString() ?? '';
          _experienceController.text = userData.yearsOfExperience.toString();
          _profilePhotoUrl = userData.profilePhoto;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _uploadPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      if (!mounted) return;
      setState(() => _isLoading = true);

      final user = context.read<AuthService>().currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Compress image
      final compressedFile = await ImageCompressionHelper.compressProfilePhoto(
        File(image.path),
      );
      if (compressedFile == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Upload to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child(user.uid)
          .child('profile.jpg');

      await ref.putFile(compressedFile);
      final downloadUrl = await ref.getDownloadURL();

      // Update Firestore and Auth
      await _firestoreService.updateUserFields(user.uid, {
        'photoURL': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _profilePhotoUrl = downloadUrl;
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('photoUpdated'.tr())));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errorUploadingPhoto'.tr())));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final user = authService.currentUser;

      if (user != null) {
        // 1. Update Auth Profile (Name, Photo)
        // Note: Phone update in Auth usually requires verification, so we might just update DB for now
        // or skip Auth phone update if it's complex. Let's update DB fields.

        // 2. Update Firestore
        final Map<String, dynamic> updates = {
          'name': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'yearsOfExperience':
              int.tryParse(_experienceController.text.trim()) ?? 0,
          'hourlyRate': double.tryParse(_hourlyRateController.text.trim()),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await _firestoreService.updateUserFields(user.uid, updates);

        // Update local auth user display name if changed
        if (_nameController.text.trim() != user.displayName) {
          // This might need a method in AuthService to update profile
          // For now, we assume Firestore update is the source of truth
        }

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('profileUpdated'.tr())));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errorUpdatingProfile'.tr(args: [e.toString()])),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('editProfile'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Photo
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      backgroundImage: _profilePhotoUrl != null
                          ? NetworkImage(_profilePhotoUrl!)
                          : null,
                      child: _profilePhotoUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: _uploadPhoto,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              CustomTextField(
                controller: _nameController,
                label: 'fullName'.tr(),
                prefixIcon: const Icon(Icons.person),
                validator: (value) => value!.isEmpty ? 'required'.tr() : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneController,
                label: 'phoneNumber'.tr(),
                prefixIcon: const Icon(Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'required'.tr() : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _experienceController,
                      label: 'yearsOfExperience'.tr(),
                      prefixIcon: const Icon(Icons.work_history),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _hourlyRateController,
                      label: 'hourlyRate'.tr(),
                      prefixIcon: const Icon(Icons.attach_money),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'saveChanges'.tr(),
                isLoading: _isLoading,
                onPressed: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}



