// File: lib/presentation/widgets/media_picker_widget.dart
// Purpose: Reusable widget for capturing/selecting photos and videos for bookings.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:uuid/uuid.dart';
import 'package:home_repair_app/models/media_file_model.dart';

/// Widget for picking and displaying photos/videos
class MediaPickerWidget extends StatefulWidget {
  /// Maximum number of photos allowed
  final int maxPhotos;

  /// Maximum number of videos allowed
  final int maxVideos;

  /// Maximum video duration in seconds
  final int maxVideoDurationSeconds;

  /// List of currently selected media files
  final List<MediaFileModel> mediaFiles;

  /// Callback when media is added
  final Function(MediaFileModel) onMediaAdded;

  /// Callback when media is removed
  final Function(String mediaId) onMediaRemoved;

  /// Whether the picker is enabled
  final bool enabled;

  const MediaPickerWidget({
    super.key,
    this.maxPhotos = 5,
    this.maxVideos = 1,
    this.maxVideoDurationSeconds = 30,
    required this.mediaFiles,
    required this.onMediaAdded,
    required this.onMediaRemoved,
    this.enabled = true,
  });

  @override
  State<MediaPickerWidget> createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends State<MediaPickerWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  int get _photoCount =>
      widget.mediaFiles.where((m) => m.type == MediaType.photo).length;
  int get _videoCount =>
      widget.mediaFiles.where((m) => m.type == MediaType.video).length;

  bool get _canAddPhoto => _photoCount < widget.maxPhotos;
  bool get _canAddVideo => _videoCount < widget.maxVideos;
  bool get _canAddMedia => _canAddPhoto || _canAddVideo;

  Future<void> _showMediaSourceDialog() async {
    if (!widget.enabled || !_canAddMedia) return;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'addMedia'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_canAddPhoto) ...[
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: Text('takePhoto'.tr()),
                subtitle: Text(
                  'photoCount'.tr(
                    args: ['$_photoCount', '${widget.maxPhotos}'],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.green),
                ),
                title: Text('chooseFromGallery'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
            if (_canAddVideo) ...[
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.videocam, color: Colors.orange),
                ),
                title: Text('recordVideo'.tr()),
                subtitle: Text(
                  'maxDuration'.tr(args: ['${widget.maxVideoDurationSeconds}']),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.video_library, color: Colors.purple),
                ),
                title: Text('chooseVideoFromGallery'.tr()),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo(ImageSource.gallery);
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!_canAddPhoto) {
      _showMaxLimitSnackbar('photos', widget.maxPhotos);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        final mediaFile = MediaFileModel(
          id: const Uuid().v4(),
          localPath: pickedFile.path,
          type: MediaType.photo,
          sizeBytes: fileSize,
          createdAt: DateTime.now(),
        );

        widget.onMediaAdded(mediaFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errorPickingImage'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    if (!_canAddVideo) {
      _showMaxLimitSnackbar('videos', widget.maxVideos);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final XFile? pickedFile = await _picker.pickVideo(
        source: source,
        maxDuration: Duration(seconds: widget.maxVideoDurationSeconds),
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();

        final mediaFile = MediaFileModel(
          id: const Uuid().v4(),
          localPath: pickedFile.path,
          type: MediaType.video,
          sizeBytes: fileSize,
          createdAt: DateTime.now(),
        );

        widget.onMediaAdded(mediaFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('errorPickingVideo'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMaxLimitSnackbar(String type, int max) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('maxMediaLimit'.tr(args: [max.toString(), type])),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _confirmRemoveMedia(MediaFileModel media) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('removeMedia'.tr()),
        content: Text('confirmRemoveMedia'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onMediaRemoved(media.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('remove'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(
              Icons.attach_file,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'attachPhotosVideos'.tr(),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              '${widget.mediaFiles.length}/${widget.maxPhotos + widget.maxVideos}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Helper text
        Text(
          'mediaHelperText'.tr(),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),

        // Media grid
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add button
              if (_canAddMedia && widget.enabled)
                GestureDetector(
                  onTap: _isLoading ? null : _showMediaSourceDialog,
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'add'.tr(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

              // Existing media
              ...widget.mediaFiles.map(
                (media) => _MediaThumbnail(
                  media: media,
                  onRemove: () => _confirmRemoveMedia(media),
                  enabled: widget.enabled,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Thumbnail widget for displaying a media file
class _MediaThumbnail extends StatelessWidget {
  final MediaFileModel media;
  final VoidCallback onRemove;
  final bool enabled;

  const _MediaThumbnail({
    required this.media,
    required this.onRemove,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: media.localPath != null
                ? Image.file(
                    File(media.localPath!),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 32),
                    ),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 32),
                  ),
          ),

          // Video indicator
          if (media.isVideo)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam, color: Colors.white, size: 12),
                    SizedBox(width: 2),
                    Text(
                      'VIDEO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Upload progress indicator
          if (!media.isUploaded && media.uploadProgress > 0)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: media.uploadProgress,
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Remove button
          if (enabled)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
