// File: lib/screens/technician/certifications_screen.dart
// Purpose: Allow technicians to manage their certifications with expiration dates.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/technician_model.dart';
import '../../models/certification.dart';
import '../../widgets/custom_button.dart';
import '../../utils/image_compression_helper.dart';

class CertificationsScreen extends StatefulWidget {
  const CertificationsScreen({super.key});

  @override
  State<CertificationsScreen> createState() => _CertificationsScreenState();
}

class _CertificationsScreenState extends State<CertificationsScreen> {
  final _firestoreService = FirestoreService();
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  List<CertificationModel> _certifications = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadCertifications();
  }

  Future<void> _loadCertifications() async {
    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      final userData = await _firestoreService.getUser(user.uid);
      if (userData is TechnicianModel && mounted) {
        setState(() {
          // Support old format for backward compatibility
          if (userData.certifications.isNotEmpty) {
            _certifications = userData.certifications.map((url) {
              return CertificationModel(
                url: url,
                expirationDate: null,
                uploadedAt: DateTime.now(),
              );
            }).toList();
          }
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadCertificate() async {
    try {
      final user = context.read<AuthService>().currentUser;
      if (user == null) return;

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Check if widget is still mounted before using context
      if (!mounted) return;

      // Show expiration date picker
      final expirationDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(days: 365)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
        helpText: 'selectExpirationDate'.tr(),
      );

      setState(() => _isUploading = true);

      // Compress image
      final compressedFile = await ImageCompressionHelper.compressImage(
        File(image.path),
      );
      if (compressedFile == null) {
        if (mounted) {
          setState(() => _isUploading = false);
        }
        return;
      }

      // Upload to Firebase Storage
      final String fileName = '${const Uuid().v4()}.jpg';
      final Reference ref = _storage
          .ref()
          .child('technician_certifications')
          .child(user.uid)
          .child(fileName);

      await ref.putFile(compressedFile);
      final String downloadUrl = await ref.getDownloadURL();

      // Create new certification
      final newCert = CertificationModel(
        url: downloadUrl,
        expirationDate: expirationDate,
        uploadedAt: DateTime.now(),
      );

      // Update Firestore - keep old format for compatibility
      final newUrls = [..._certifications.map((e) => e.url), downloadUrl];
      await _firestoreService.updateUserFields(user.uid, {
        'certifications': newUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _certifications.add(newCert);
          _isUploading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('certificateUploaded'.tr())));
      }
    } catch (e) {
      debugPrint('Error uploading certificate: $e');
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errorUploadingImage'.tr())));
      }
    }
  }

  Future<void> _deleteCertificate(CertificationModel cert) async {
    try {
      final user = context.read<AuthService>().currentUser;
      if (user == null) return;

      setState(() => _isLoading = true);

      // Delete from Storage
      try {
        final ref = _storage.refFromURL(cert.url);
        await ref.delete();
      } catch (e) {
        debugPrint('Error deleting file from storage: $e');
      }

      // Update Firestore
      final newCerts = List<CertificationModel>.from(_certifications)
        ..remove(cert);
      final newUrls = newCerts.map((e) => e.url).toList();

      await _firestoreService.updateUserFields(user.uid, {
        'certifications': newUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _certifications = newCerts;
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('certificateDeleted'.tr())));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errorDeletingImage'.tr())));
      }
    }
  }

  Widget _buildExpirationBadge(CertificationModel cert) {
    if (cert.expirationDate == null) return const SizedBox.shrink();

    Color badgeColor;
    IconData icon;
    String text;

    if (cert.isExpired) {
      badgeColor = Colors.red;
      icon = Icons.error;
      text = 'expired'.tr();
    } else if (cert.isExpiringSoon) {
      badgeColor = Colors.orange;
      icon = Icons.warning;
      text = 'expiringSoon'.tr();
    } else {
      badgeColor = Colors.green;
      icon = Icons.check_circle;
      text = 'valid'.tr();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('certifications'.tr())),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _certifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.card_membership,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'noCertifications'.tr(),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _certifications.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final cert = _certifications[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 200,
                                    width: double.infinity,
                                    child: Image.network(
                                      cert.url,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }

                                            return Center(
                                              child: CircularProgressIndicator(
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${'certificate'.tr()} ${index + 1}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              if (cert.expirationDate !=
                                                  null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${'expires'.tr()}: ${DateFormat.yMMMd().format(cert.expirationDate!)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                _buildExpirationBadge(cert),
                                              ],
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _deleteCertificate(cert),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    text: 'uploadCertificate'.tr(),
                    isLoading: _isUploading,
                    icon: Icons.upload_file,
                    onPressed: _pickAndUploadCertificate,
                  ),
                ),
              ],
            ),
    );
  }
}
