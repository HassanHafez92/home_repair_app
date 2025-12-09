/// Domain entity representing a technician user.

import 'package:equatable/equatable.dart';
import 'user_entity.dart';

/// Technician approval status.
enum TechnicianStatus { pending, approved, rejected, suspended }

/// Technician-specific user entity with professional details.
class TechnicianEntity extends Equatable {
  final String id;
  final String email;
  final String? phoneNumber;
  final String fullName;
  final String? profilePhoto;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastActive;
  final bool? emailVerified;
  final String? nationalId;
  final List<String> specializations;
  final List<String> portfolioUrls;
  final List<String> serviceAreas;
  final List<String> certifications;
  final int yearsOfExperience;
  final double? hourlyRate;
  final TechnicianStatus status;
  final double rating;
  final int completedJobs;
  final bool isAvailable;
  final Map<String, dynamic>? location;

  const TechnicianEntity({
    required this.id,
    required this.email,
    this.phoneNumber,
    required this.fullName,
    this.profilePhoto,
    required this.createdAt,
    required this.updatedAt,
    required this.lastActive,
    this.emailVerified,
    this.nationalId,
    this.specializations = const [],
    this.portfolioUrls = const [],
    this.serviceAreas = const [],
    this.certifications = const [],
    this.yearsOfExperience = 0,
    this.hourlyRate,
    this.status = TechnicianStatus.pending,
    this.rating = 0.0,
    this.completedJobs = 0,
    this.isAvailable = false,
    this.location,
  });

  UserRole get role => UserRole.technician;

  @override
  List<Object?> get props => [
    id,
    email,
    phoneNumber,
    fullName,
    profilePhoto,
    createdAt,
    updatedAt,
    lastActive,
    emailVerified,
    nationalId,
    specializations,
    portfolioUrls,
    serviceAreas,
    certifications,
    yearsOfExperience,
    hourlyRate,
    status,
    rating,
    completedJobs,
    isAvailable,
    location,
  ];

  /// Convert to base UserEntity for polymorphic use.
  UserEntity toUserEntity() => UserEntity(
    id: id,
    email: email,
    phoneNumber: phoneNumber,
    fullName: fullName,
    profilePhoto: profilePhoto,
    role: UserRole.technician,
    createdAt: createdAt,
    updatedAt: updatedAt,
    lastActive: lastActive,
    emailVerified: emailVerified,
  );

  TechnicianEntity copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? fullName,
    String? profilePhoto,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActive,
    bool? emailVerified,
    String? nationalId,
    List<String>? specializations,
    List<String>? portfolioUrls,
    List<String>? serviceAreas,
    List<String>? certifications,
    int? yearsOfExperience,
    double? hourlyRate,
    TechnicianStatus? status,
    double? rating,
    int? completedJobs,
    bool? isAvailable,
    Map<String, dynamic>? location,
  }) {
    return TechnicianEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActive: lastActive ?? this.lastActive,
      emailVerified: emailVerified ?? this.emailVerified,
      nationalId: nationalId ?? this.nationalId,
      specializations: specializations ?? this.specializations,
      portfolioUrls: portfolioUrls ?? this.portfolioUrls,
      serviceAreas: serviceAreas ?? this.serviceAreas,
      certifications: certifications ?? this.certifications,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      completedJobs: completedJobs ?? this.completedJobs,
      isAvailable: isAvailable ?? this.isAvailable,
      location: location ?? this.location,
    );
  }
}
