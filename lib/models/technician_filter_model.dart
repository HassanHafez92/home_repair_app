// File: lib/models/technician_filter_model.dart
// Purpose: Model for filtering technicians during booking/search.

import 'package:equatable/equatable.dart';

/// Model representing filter criteria for technician search
class TechnicianFilterModel extends Equatable {
  /// Minimum rating (1.0 to 5.0)
  final double? minRating;

  /// Only show verified technicians
  final bool verifiedOnly;

  /// Preferred technician ID (for "same technician" preference)
  final String? preferredTechnicianId;

  /// Preferred technician name (for display)
  final String? preferredTechnicianName;

  /// Required specializations (e.g., ['plumbing', 'electrical'])
  final List<String> specializations;

  /// Maximum distance in kilometers
  final double? maxDistanceKm;

  /// Preferred availability time slots
  final List<TimeSlot> availabilitySlots;

  /// Sort order for results
  final TechnicianSortOrder sortOrder;

  /// Minimum years of experience
  final int? minYearsExperience;

  /// Minimum completed jobs
  final int? minCompletedJobs;

  const TechnicianFilterModel({
    this.minRating,
    this.verifiedOnly = false,
    this.preferredTechnicianId,
    this.preferredTechnicianName,
    this.specializations = const [],
    this.maxDistanceKm,
    this.availabilitySlots = const [],
    this.sortOrder = TechnicianSortOrder.bestMatch,
    this.minYearsExperience,
    this.minCompletedJobs,
  });

  /// Check if any filters are active
  bool get hasActiveFilters =>
      minRating != null ||
      verifiedOnly ||
      preferredTechnicianId != null ||
      specializations.isNotEmpty ||
      maxDistanceKm != null ||
      availabilitySlots.isNotEmpty ||
      minYearsExperience != null ||
      minCompletedJobs != null;

  /// Count of active filters
  int get activeFilterCount {
    int count = 0;
    if (minRating != null) count++;
    if (verifiedOnly) count++;
    if (preferredTechnicianId != null) count++;
    if (specializations.isNotEmpty) count++;
    if (maxDistanceKm != null) count++;
    if (availabilitySlots.isNotEmpty) count++;
    if (minYearsExperience != null) count++;
    if (minCompletedJobs != null) count++;
    return count;
  }

  /// Create a copy with updated values
  TechnicianFilterModel copyWith({
    double? minRating,
    bool? verifiedOnly,
    String? preferredTechnicianId,
    String? preferredTechnicianName,
    List<String>? specializations,
    double? maxDistanceKm,
    List<TimeSlot>? availabilitySlots,
    TechnicianSortOrder? sortOrder,
    int? minYearsExperience,
    int? minCompletedJobs,
    bool clearMinRating = false,
    bool clearPreferredTechnician = false,
    bool clearMaxDistance = false,
    bool clearMinYearsExperience = false,
    bool clearMinCompletedJobs = false,
  }) {
    return TechnicianFilterModel(
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      preferredTechnicianId: clearPreferredTechnician
          ? null
          : (preferredTechnicianId ?? this.preferredTechnicianId),
      preferredTechnicianName: clearPreferredTechnician
          ? null
          : (preferredTechnicianName ?? this.preferredTechnicianName),
      specializations: specializations ?? this.specializations,
      maxDistanceKm: clearMaxDistance
          ? null
          : (maxDistanceKm ?? this.maxDistanceKm),
      availabilitySlots: availabilitySlots ?? this.availabilitySlots,
      sortOrder: sortOrder ?? this.sortOrder,
      minYearsExperience: clearMinYearsExperience
          ? null
          : (minYearsExperience ?? this.minYearsExperience),
      minCompletedJobs: clearMinCompletedJobs
          ? null
          : (minCompletedJobs ?? this.minCompletedJobs),
    );
  }

  /// Reset all filters to default
  factory TechnicianFilterModel.reset() => const TechnicianFilterModel();

  @override
  List<Object?> get props => [
    minRating,
    verifiedOnly,
    preferredTechnicianId,
    preferredTechnicianName,
    specializations,
    maxDistanceKm,
    availabilitySlots,
    sortOrder,
    minYearsExperience,
    minCompletedJobs,
  ];
}

/// Time slot for availability preferences
class TimeSlot extends Equatable {
  /// Day of week (1 = Monday, 7 = Sunday)
  final int dayOfWeek;

  /// Start hour (0-23)
  final int startHour;

  /// End hour (0-23)
  final int endHour;

  const TimeSlot({
    required this.dayOfWeek,
    required this.startHour,
    required this.endHour,
  });

  /// Get human-readable day name
  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  /// Get formatted time range
  String get timeRange =>
      '${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00';

  @override
  List<Object?> get props => [dayOfWeek, startHour, endHour];
}

/// Sort order for technician results
enum TechnicianSortOrder {
  /// Best match based on rating, distance, and availability
  bestMatch,

  /// Highest rating first
  highestRating,

  /// Nearest first
  nearestFirst,

  /// Most experienced first
  mostExperienced,

  /// Most jobs completed first
  mostJobs,

  /// Lowest price first (if applicable)
  lowestPrice,
}
