// File: lib/screens/technician/portfolio_screen.dart
// Purpose: Allow technicians to manage their portfolio images with captions.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../helpers/auth_helper.dart';
import 'package:home_repair_app/domain/repositories/i_user_repository.dart';
import 'package:home_repair_app/core/di/injection_container.dart';
import 'package:home_repair_app/models/portfolio_item.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/caption_input_dialog.dart';
import 'package:home_repair_app/utils/image_compression_helper.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final _userRepository = sl<IUserRepository>();
  final _picker = ImagePicker();
  final _storage = FirebaseStorage.instance;

  List<PortfolioItem> _portfolio = [];
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    final userId = context.userId;
    if (userId != null) {
      final result = await _userRepository.getTechnician(userId);
      result.fold(
        (failure) {
          if (mounted) setState(() => _isLoading = false);
        },
        (technician) {
          if (technician != null && mounted) {
            setState(() {
              if (technician.portfolioUrls.isNotEmpty) {
                _portfolio = technician.portfolioUrls.map((url) {
                  return PortfolioItem(
                    url: url,
                    caption: null,
                    uploadedAt: DateTime.now(),
                  );
                }).toList();
              }
              _isLoading = false;
            });
          } else if (mounted) {
            setState(() => _isLoading = false);
          }
        },
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final userId = context.userId;
      if (userId == null) return;

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      if (!mounted) return;

      // Show caption dialog
      final caption = await showDialog<String>(
        context: context,
        builder: (context) => const CaptionInputDialog(),
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
          .child('technician_portfolios')
          .child(userId)
          .child(fileName);

      await ref.putFile(compressedFile);
      final String downloadUrl = await ref.getDownloadURL();

      // Create new portfolio item
      final newItem = PortfolioItem(
        url: downloadUrl,
        caption: caption,
        uploadedAt: DateTime.now(),
      );

      // Update Firestore - keep old format for compatibility
      final newUrls = [..._portfolio.map((e) => e.url), downloadUrl];
      await _userRepository.updateUserFields(userId, {
        'portfolioUrls': newUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _portfolio.add(newItem);
          _isUploading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('imageUploaded'.tr())));
      }
    } catch (e) {
      debugPrint('Error uploading image: $e');
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('errorUploadingImage'.tr())));
      }
    }
  }

  Future<void> _deleteImage(PortfolioItem item) async {
    try {
      final userId = context.userId;
      if (userId == null) return;

      setState(() => _isLoading = true);

      // Delete from Storage
      try {
        final ref = _storage.refFromURL(item.url);
        await ref.delete();
      } catch (e) {
        debugPrint('Error deleting file from storage: $e');
      }

      // Update Firestore
      final newPortfolio = List<PortfolioItem>.from(_portfolio)..remove(item);
      final newUrls = newPortfolio.map((e) => e.url).toList();

      await _userRepository.updateUserFields(userId, {
        'portfolioUrls': newUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          _portfolio = newPortfolio;
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('imageDeleted'.tr())));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('portfolio'.tr())),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _portfolio.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.photo_library_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'noPortfolioImages'.tr(),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                          itemCount: _portfolio.length,
                          itemBuilder: (context, index) {
                            final item = _portfolio[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          item.url,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
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
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.black54,
                                            radius: 16,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              onPressed: () =>
                                                  _deleteImage(item),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (item.caption != null)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        item.caption!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
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
                    text: 'addPhoto'.tr(),
                    isLoading: _isUploading,
                    icon: Icons.add_a_photo,
                    onPressed: _pickAndUploadImage,
                  ),
                ),
              ],
            ),
    );
  }
}
