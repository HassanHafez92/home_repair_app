// File: lib/models/warranty_model.dart
// Purpose: Models for service warranties and guarantees.

import 'package:equatable/equatable.dart';

/// Status of a warranty
enum WarrantyStatus {
  /// Warranty is active
  active,

  /// Warranty has expired
  expired,

  /// Warranty claim in progress
  claimInProgress,

  /// Warranty claim fulfilled
  claimFulfilled,

  /// Warranty voided (e.g., due to misuse)
  voided,
}

/// Model for service warranties
class WarrantyModel extends Equatable {
  /// Unique warranty ID
  final String id;

  /// Associated order ID
  final String orderId;

  /// Customer ID
  final String customerId;

  /// Service name
  final String serviceName;

  /// Service category
  final String category;

  /// Technician who performed the service
  final String technicianId;
  final String technicianName;

  /// Warranty start date (service completion date)
  final DateTime startDate;

  /// Warranty end date
  final DateTime endDate;

  /// Warranty duration in days
  final int durationDays;

  /// Current status
  final WarrantyStatus status;

  /// Coverage description
  final String coverageDescription;

  /// What's not covered
  final List<String> exclusions;

  /// Maximum claim value in EGP
  final double? maxClaimValue;

  /// Number of claims made
  final int claimCount;

  /// Maximum number of claims allowed
  final int maxClaims;

  const WarrantyModel({
    required this.id,
    required this.orderId,
    required this.customerId,
    required this.serviceName,
    required this.category,
    required this.technicianId,
    required this.technicianName,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    this.status = WarrantyStatus.active,
    required this.coverageDescription,
    this.exclusions = const [],
    this.maxClaimValue,
    this.claimCount = 0,
    this.maxClaims = 1,
  });

  /// Check if warranty is still active
  bool get isActive =>
      status == WarrantyStatus.active && DateTime.now().isBefore(endDate);

  /// Days remaining on warranty
  int get daysRemaining {
    if (!isActive) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Percentage of warranty period remaining
  double get percentageRemaining {
    if (!isActive) return 0;
    return daysRemaining / durationDays;
  }

  /// Check if claims are still available
  bool get canClaim => isActive && claimCount < maxClaims;

  Map<String, dynamic> toJson() => {
    'id': id,
    'orderId': orderId,
    'customerId': customerId,
    'serviceName': serviceName,
    'category': category,
    'technicianId': technicianId,
    'technicianName': technicianName,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'durationDays': durationDays,
    'status': status.name,
    'coverageDescription': coverageDescription,
    'exclusions': exclusions,
    'maxClaimValue': maxClaimValue,
    'claimCount': claimCount,
    'maxClaims': maxClaims,
  };

  factory WarrantyModel.fromJson(Map<String, dynamic> json) {
    return WarrantyModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      customerId: json['customerId'] as String,
      serviceName: json['serviceName'] as String,
      category: json['category'] as String,
      technicianId: json['technicianId'] as String,
      technicianName: json['technicianName'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      durationDays: json['durationDays'] as int,
      status: WarrantyStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => WarrantyStatus.active,
      ),
      coverageDescription: json['coverageDescription'] as String,
      exclusions: (json['exclusions'] as List<dynamic>?)?.cast<String>() ?? [],
      maxClaimValue: (json['maxClaimValue'] as num?)?.toDouble(),
      claimCount: json['claimCount'] as int? ?? 0,
      maxClaims: json['maxClaims'] as int? ?? 1,
    );
  }

  /// Create a standard warranty for a service
  factory WarrantyModel.standard({
    required String id,
    required String orderId,
    required String customerId,
    required String serviceName,
    required String category,
    required String technicianId,
    required String technicianName,
    required DateTime serviceDate,
  }) {
    return WarrantyModel(
      id: id,
      orderId: orderId,
      customerId: customerId,
      serviceName: serviceName,
      category: category,
      technicianId: technicianId,
      technicianName: technicianName,
      startDate: serviceDate,
      endDate: serviceDate.add(const Duration(days: 30)),
      durationDays: 30,
      coverageDescription:
          '30-day workmanship guarantee. If the same issue reoccurs, '
          'we will fix it at no additional charge.',
      exclusions: [
        'Damage due to misuse',
        'Normal wear and tear',
        'Issues unrelated to the original service',
      ],
    );
  }

  @override
  List<Object?> get props => [id, orderId, status, endDate];
}

/// Model for warranty claims
class WarrantyClaimModel extends Equatable {
  final String id;
  final String warrantyId;
  final String customerId;
  final String description;
  final List<String> photoUrls;
  final DateTime createdAt;
  final WarrantyClaimStatus status;
  final String? resolutionNotes;
  final DateTime? resolvedAt;

  const WarrantyClaimModel({
    required this.id,
    required this.warrantyId,
    required this.customerId,
    required this.description,
    this.photoUrls = const [],
    required this.createdAt,
    this.status = WarrantyClaimStatus.pending,
    this.resolutionNotes,
    this.resolvedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'warrantyId': warrantyId,
    'customerId': customerId,
    'description': description,
    'photoUrls': photoUrls,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'resolutionNotes': resolutionNotes,
    'resolvedAt': resolvedAt?.toIso8601String(),
  };

  factory WarrantyClaimModel.fromJson(Map<String, dynamic> json) {
    return WarrantyClaimModel(
      id: json['id'] as String,
      warrantyId: json['warrantyId'] as String,
      customerId: json['customerId'] as String,
      description: json['description'] as String,
      photoUrls: (json['photoUrls'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: WarrantyClaimStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => WarrantyClaimStatus.pending,
      ),
      resolutionNotes: json['resolutionNotes'] as String?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, warrantyId, status];
}

enum WarrantyClaimStatus { pending, underReview, approved, rejected, fulfilled }
