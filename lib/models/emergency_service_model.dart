// File: lib/models/emergency_service_model.dart
// Purpose: Model for emergency/urgent service bookings with premium pricing.

import 'package:equatable/equatable.dart';

/// Priority levels for service requests
enum ServicePriority {
  /// Normal service - standard scheduling
  normal,

  /// Same day service - higher priority
  sameDay,

  /// Urgent service - within 2 hours
  urgent,

  /// Emergency service - immediate dispatch
  emergency,
}

/// Model for emergency/priority service configuration
class EmergencyServiceModel extends Equatable {
  /// Service priority level
  final ServicePriority priority;

  /// Base service price
  final double basePrice;

  /// Priority multiplier applied to base price
  final double priorityMultiplier;

  /// Flat priority fee (added on top of multiplied price)
  final double priorityFee;

  /// Maximum response time in minutes
  final int maxResponseTimeMinutes;

  /// Whether this is an emergency (water leak, power outage, etc.)
  final bool isEmergency;

  /// Emergency type description
  final String? emergencyType;

  /// Special instructions for the technician
  final String? specialInstructions;

  /// Whether to dispatch nearest available technician
  final bool dispatchNearest;

  const EmergencyServiceModel({
    this.priority = ServicePriority.normal,
    required this.basePrice,
    this.priorityMultiplier = 1.0,
    this.priorityFee = 0.0,
    this.maxResponseTimeMinutes = 120,
    this.isEmergency = false,
    this.emergencyType,
    this.specialInstructions,
    this.dispatchNearest = false,
  });

  /// Get total price including priority fees
  double get totalPrice => (basePrice * priorityMultiplier) + priorityFee;

  /// Get additional cost over normal price
  double get additionalCost => totalPrice - basePrice;

  /// Get priority label for display
  String get priorityLabel {
    switch (priority) {
      case ServicePriority.normal:
        return 'Normal';
      case ServicePriority.sameDay:
        return 'Same Day';
      case ServicePriority.urgent:
        return 'Urgent (2 hours)';
      case ServicePriority.emergency:
        return 'Emergency';
    }
  }

  /// Get response time description
  String get responseTimeDisplay {
    if (maxResponseTimeMinutes < 60) {
      return '$maxResponseTimeMinutes minutes';
    }
    final hours = maxResponseTimeMinutes ~/ 60;
    final mins = maxResponseTimeMinutes % 60;
    if (mins == 0) {
      return '$hours hours';
    }
    return '${hours}h ${mins}m';
  }

  /// Create configuration for different priority levels
  factory EmergencyServiceModel.withPriority({
    required ServicePriority priority,
    required double basePrice,
  }) {
    switch (priority) {
      case ServicePriority.normal:
        return EmergencyServiceModel(
          priority: priority,
          basePrice: basePrice,
          priorityMultiplier: 1.0,
          priorityFee: 0,
          maxResponseTimeMinutes: 1440, // 24 hours
        );
      case ServicePriority.sameDay:
        return EmergencyServiceModel(
          priority: priority,
          basePrice: basePrice,
          priorityMultiplier: 1.25, // 25% more
          priorityFee: 50, // 50 EGP fee
          maxResponseTimeMinutes: 480, // 8 hours
        );
      case ServicePriority.urgent:
        return EmergencyServiceModel(
          priority: priority,
          basePrice: basePrice,
          priorityMultiplier: 1.5, // 50% more
          priorityFee: 100, // 100 EGP fee
          maxResponseTimeMinutes: 120, // 2 hours
          dispatchNearest: true,
        );
      case ServicePriority.emergency:
        return EmergencyServiceModel(
          priority: priority,
          basePrice: basePrice,
          priorityMultiplier: 2.0, // 100% more
          priorityFee: 200, // 200 EGP fee
          maxResponseTimeMinutes: 30, // 30 minutes
          isEmergency: true,
          dispatchNearest: true,
        );
    }
  }

  EmergencyServiceModel copyWith({
    ServicePriority? priority,
    double? basePrice,
    double? priorityMultiplier,
    double? priorityFee,
    int? maxResponseTimeMinutes,
    bool? isEmergency,
    String? emergencyType,
    String? specialInstructions,
    bool? dispatchNearest,
  }) {
    return EmergencyServiceModel(
      priority: priority ?? this.priority,
      basePrice: basePrice ?? this.basePrice,
      priorityMultiplier: priorityMultiplier ?? this.priorityMultiplier,
      priorityFee: priorityFee ?? this.priorityFee,
      maxResponseTimeMinutes:
          maxResponseTimeMinutes ?? this.maxResponseTimeMinutes,
      isEmergency: isEmergency ?? this.isEmergency,
      emergencyType: emergencyType ?? this.emergencyType,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      dispatchNearest: dispatchNearest ?? this.dispatchNearest,
    );
  }

  @override
  List<Object?> get props => [
    priority,
    basePrice,
    priorityMultiplier,
    priorityFee,
    maxResponseTimeMinutes,
    isEmergency,
    emergencyType,
    specialInstructions,
    dispatchNearest,
  ];
}

/// Common emergency types
class EmergencyTypes {
  static const String waterLeak = 'Water Leak';
  static const String powerOutage = 'Power Outage';
  static const String gasLeak = 'Gas Leak';
  static const String lockedOut = 'Locked Out';
  static const String brokenPipe = 'Broken Pipe';
  static const String acNotWorking = 'AC Not Working (Summer)';
  static const String heatingNotWorking = 'Heating Not Working (Winter)';
  static const String securityIssue = 'Security Issue';

  static List<String> get all => [
    waterLeak,
    powerOutage,
    gasLeak,
    lockedOut,
    brokenPipe,
    acNotWorking,
    heatingNotWorking,
    securityIssue,
  ];
}
