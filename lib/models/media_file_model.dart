// File: lib/models/media_file_model.dart
// Purpose: Model representing a media file (photo or video) for booking attachments.

import 'package:equatable/equatable.dart';

/// Enum representing the type of media file
enum MediaType { photo, video }

/// Model representing a media file attached to a booking
class MediaFileModel extends Equatable {
  /// Unique identifier for the media file
  final String id;

  /// Local file path (before upload)
  final String? localPath;

  /// Remote URL (after upload to Firebase Storage)
  final String? remoteUrl;

  /// Type of media (photo or video)
  final MediaType type;

  /// Thumbnail URL for videos
  final String? thumbnailUrl;

  /// Duration in seconds (for videos only)
  final int? durationSeconds;

  /// File size in bytes
  final int? sizeBytes;

  /// Upload progress (0.0 to 1.0)
  final double uploadProgress;

  /// Whether the file has been uploaded
  final bool isUploaded;

  /// Optional caption for the media
  final String? caption;

  /// Timestamp when the media was captured/selected
  final DateTime createdAt;

  const MediaFileModel({
    required this.id,
    this.localPath,
    this.remoteUrl,
    required this.type,
    this.thumbnailUrl,
    this.durationSeconds,
    this.sizeBytes,
    this.uploadProgress = 0.0,
    this.isUploaded = false,
    this.caption,
    required this.createdAt,
  });

  /// Check if this is a video
  bool get isVideo => type == MediaType.video;

  /// Check if this is a photo
  bool get isPhoto => type == MediaType.photo;

  /// Get the display URL (remote if uploaded, otherwise local)
  String? get displayPath => isUploaded ? remoteUrl : localPath;

  /// Create a copy with updated fields
  MediaFileModel copyWith({
    String? id,
    String? localPath,
    String? remoteUrl,
    MediaType? type,
    String? thumbnailUrl,
    int? durationSeconds,
    int? sizeBytes,
    double? uploadProgress,
    bool? isUploaded,
    String? caption,
    DateTime? createdAt,
  }) {
    return MediaFileModel(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      type: type ?? this.type,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isUploaded: isUploaded ?? this.isUploaded,
      caption: caption ?? this.caption,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'remoteUrl': remoteUrl,
      'type': type.name,
      'thumbnailUrl': thumbnailUrl,
      'durationSeconds': durationSeconds,
      'sizeBytes': sizeBytes,
      'caption': caption,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from JSON (from Firestore)
  factory MediaFileModel.fromJson(Map<String, dynamic> json) {
    return MediaFileModel(
      id: json['id'] as String,
      remoteUrl: json['remoteUrl'] as String?,
      type: MediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MediaType.photo,
      ),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      sizeBytes: json['sizeBytes'] as int?,
      isUploaded: true,
      caption: json['caption'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    localPath,
    remoteUrl,
    type,
    thumbnailUrl,
    durationSeconds,
    sizeBytes,
    uploadProgress,
    isUploaded,
    caption,
    createdAt,
  ];
}
