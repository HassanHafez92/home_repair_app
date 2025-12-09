// File: lib/screens/auth/technician_signup_screen.dart
// Purpose: Professional registration for technicians with verification.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/technician_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class TechnicianSignupScreen extends StatefulWidget {
  const TechnicianSignupScreen({super.key});

  @override
  State<TechnicianSignupScreen> createState() => _TechnicianSignupScreenState();
}

class _TechnicianSignupScreenState extends State<TechnicianSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _experienceController = TextEditingController();

  final List<String> _selectedSpecializations = [];
  bool _isSubmitting = false;

  final List<String> _availableSpecializations = [
    'Plumbing',
    'Electrical',
    'AC Repair',
    'Carpentry',
    'Painting',
    'Appliances',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nationalIdController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecializations.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('selectOneSpecialization'.tr())));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();

      // 1. Create Auth User
      final credential = await authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (credential.user != null) {
        // 2. Create Firestore Technician Document
        final newTechnician = TechnicianModel(
          id: credential.user!.uid,
          email: _emailController.text.trim(),
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          nationalId: _nationalIdController.text.trim(),
          specializations: _selectedSpecializations,
          yearsOfExperience: int.tryParse(_experienceController.text) ?? 0,
          status: TechnicianStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        await firestoreService.createUser(newTechnician);

        if (mounted) {
          // Show verification pending message
          await showDialog(
            context: context,
            barrierDismissible: false, // Prevent dismissing by tapping outside
            builder: (_) => AlertDialog(
              title: Text('registrationSubmitted'.tr()),
              content: Text('registrationSubmittedMessage'.tr()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                  },
                  child: Text('ok'.tr()),
                ),
              ],
            ),
          );

          // Navigate to login screen after dialog is closed
          if (mounted) {
            context.go('/login');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('professionalRegistration'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'joinAsProfessionalTitle'.tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'fillProfessionalDetails'.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // Personal Info
              CustomTextField(
                label: 'fullName'.tr(),
                hint: 'enterYourFullName'.tr(),
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'required'.tr();
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'email'.tr(),
                hint: 'enterYourEmail'.tr(),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'required'.tr();
                  if (!value.contains('@')) return 'invalidEmail'.tr();
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'phoneNumber'.tr(),
                hint: 'enterYourPhoneNumber'.tr(),
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'required'.tr();
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'password'.tr(),
                hint: 'createAPassword'.tr(),
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'required'.tr();
                  if (value.length < 6) return 'min6Chars'.tr();
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Professional Info
              Text(
                'professionalInformation'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'nationalId'.tr(),
                hint: 'enterYourNationalId'.tr(),
                controller: _nationalIdController,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'required'.tr();
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'yearsOfExperience'.tr(),
                hint: 'enterYearsOfExperience'.tr(),
                controller: _experienceController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'required'.tr();
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Specializations
              Text(
                'specializations'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableSpecializations.map((spec) {
                  return FilterChip(
                    label: Text(
                      'spec$spec'.replaceAll(' ', ''),
                    ), // e.g. specPlumbing
                    selected: _selectedSpecializations.contains(spec),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSpecializations.add(spec);
                        } else {
                          _selectedSpecializations.remove(spec);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Info Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'verificationRequired'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'verificationNote'.tr(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'submitApplication'.tr(),
                onPressed: _signup,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
