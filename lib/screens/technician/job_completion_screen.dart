// File: lib/screens/technician/job_completion_screen.dart
// Purpose: Complete job with final price, photos, and notes.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

class JobCompletionScreen extends StatefulWidget {
  final OrderModel order;

  const JobCompletionScreen({super.key, required this.order});

  @override
  State<JobCompletionScreen> createState() => _JobCompletionScreenState();
}

class _JobCompletionScreenState extends State<JobCompletionScreen> {
  final _finalPriceController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  File? _beforeImage;
  File? _afterImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Pre-fill with estimate if available
    if (widget.order.initialEstimate != null) {
      _finalPriceController.text = widget.order.initialEstimate!
          .toInt()
          .toString();
    }
  }

  @override
  void dispose() {
    _finalPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isBefore) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          if (isBefore) {
            _beforeImage = File(pickedFile.path);
          } else {
            _afterImage = File(pickedFile.path);
          }
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

  Future<void> _completeJob() async {
    final finalPrice = double.tryParse(_finalPriceController.text);
    if (finalPrice == null || finalPrice <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('enterValidFinalPrice'.tr())));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );

      // In a real app, upload images to Firebase Storage here and get URLs
      // List<String> photoUrls = await _uploadPhotos();

      // Update order with final price and complete status
      await firestoreService.completeOrder(
        widget.order.id,
        finalPrice,
        _notesController.text,
      );

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('jobCompletedSuccess'.tr())));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errorMessage'.tr(args: [e.toString()])),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('completeJobTitle'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'jobId'.tr(args: [widget.order.id.substring(0, 8)]),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(widget.order.description),
                    const SizedBox(height: 8),
                    if (widget.order.initialEstimate != null)
                      Text(
                        'initialEstimate'.tr(
                          args: [
                            widget.order.initialEstimate!.toInt().toString(),
                          ],
                        ),
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Photos
            Text(
              'beforeAfterPhotos'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPhotoPlaceholder(
                    'before'.tr(),
                    _beforeImage,
                    true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPhotoPlaceholder(
                    'after'.tr(),
                    _afterImage,
                    false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Final Price
            Text(
              'finalPriceTitle'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'finalPriceLabel'.tr(),
              hint: 'finalPriceHint'.tr(),
              controller: _finalPriceController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Notes
            Text(
              'workNotes'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'notesLabel'.tr(),
              hint: 'notesHint'.tr(),
              controller: _notesController,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // Complete Button
            CustomButton(
              text: 'completeAndInvoice'.tr(),
              onPressed: _completeJob,
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder(String label, File? image, bool isBefore) {
    return InkWell(
      onTap: () => _pickImage(isBefore),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[400]!,
            width: 2,
            style: BorderStyle.solid,
          ),
          image: image != null
              ? DecorationImage(image: FileImage(image), fit: BoxFit.cover)
              : null,
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(label, style: const TextStyle(color: Colors.grey)),
                ],
              )
            : null,
      ),
    );
  }
}
