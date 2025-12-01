// File: lib/screens/customer/edit_profile_screen.dart
// Purpose: Edit user profile information including name, phone, and profile picture using BLoC.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final state = context.read<ProfileBloc>().state;
    if (state.user != null) {
      _nameController.text = state.user!.fullName;
      _phoneController.text = state.user!.phoneNumber ?? '';
      _emailController.text = state.user!.email;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('errorPickingImage'.tr(args: [e.toString()]))),
        );
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text('camera'.tr()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('gallery'.tr()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'removePhoto'.tr(),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final bloc = context.read<ProfileBloc>();

    // Upload image if selected
    if (_selectedImage != null) {
      bloc.add(ProfileImageUpdateRequested(_selectedImage!));
    }

    // Update text fields
    bloc.add(
      ProfileUpdateRequested(
        fullName: _nameController.text,
        phoneNumber: _phoneController.text,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('editProfile'.tr())),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('profileUpdated'.tr())));
            // We don't pop here because user might want to stay
            // But usually we pop. Let's pop if it was a save action.
            // However, BLoC emits success for both load and update.
            // We need to differentiate or just show snackbar.
            // For now, just show snackbar.
          } else if (state.status == ProfileStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'errorMessage'.tr(args: [state.errorMessage ?? '']),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == ProfileStatus.loading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Picture
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.blue[100],
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : state.user?.profilePhoto != null
                              ? NetworkImage(state.user!.profilePhoto!)
                              : null,
                          child:
                              (_selectedImage == null &&
                                  state.user?.profilePhoto == null)
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.blue,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: _showImageSourceDialog,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Full Name Field
                  CustomTextField(
                    controller: _nameController,
                    label: 'fullName'.tr(),
                    hint: 'enterYourFullName'.tr(),
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'pleaseEnterName'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email Field (Read-only)
                  CustomTextField(
                    controller: _emailController,
                    label: 'email'.tr(),
                    prefixIcon: const Icon(Icons.email_outlined),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  CustomTextField(
                    controller: _phoneController,
                    label: 'phoneNumber'.tr(),
                    hint: 'enterYourPhoneNumber'.tr(),
                    prefixIcon: const Icon(Icons.phone_outlined),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'pleaseEnterPhoneNumber'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  CustomButton(
                    text: 'saveChanges'.tr(),
                    onPressed: isLoading ? null : _saveProfile,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
