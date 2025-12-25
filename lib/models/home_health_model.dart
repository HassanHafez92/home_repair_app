// File: lib/models/home_health_model.dart
// Purpose: Model for customer's home health analytics and maintenance tracking.

import 'package:equatable/equatable.dart';

/// Model for home health analytics
class HomeHealthModel extends Equatable {
  /// User ID
  final String userId;

  /// Total amount spent on services (EGP)
  final double totalSpending;

  /// Monthly spending breakdown (month -> amount)
  final Map<String, double> monthlySpending;

  /// Spending by category (category -> amount)
  final Map<String, double> categorySpending;

  /// Total number of services completed
  final int totalServices;

  /// Services by category count
  final Map<String, int> servicesByCategory;

  /// Upcoming maintenance reminders
  final List<MaintenanceReminder> upcomingReminders;

  /// Last service date for each category
  final Map<String, DateTime> lastServiceByCategory;

  /// Property details
  final PropertyInfo? propertyInfo;

  const HomeHealthModel({
    required this.userId,
    this.totalSpending = 0,
    this.monthlySpending = const {},
    this.categorySpending = const {},
    this.totalServices = 0,
    this.servicesByCategory = const {},
    this.upcomingReminders = const [],
    this.lastServiceByCategory = const {},
    this.propertyInfo,
  });

  /// Get top spending category
  String? get topSpendingCategory {
    if (categorySpending.isEmpty) return null;
    return categorySpending.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get average spending per service
  double get averageServiceCost =>
      totalServices > 0 ? totalSpending / totalServices : 0;

  /// Get current month spending
  double get currentMonthSpending {
    final now = DateTime.now();
    final key = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    return monthlySpending[key] ?? 0;
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'totalSpending': totalSpending,
    'monthlySpending': monthlySpending,
    'categorySpending': categorySpending,
    'totalServices': totalServices,
    'servicesByCategory': servicesByCategory,
    'upcomingReminders': upcomingReminders.map((r) => r.toJson()).toList(),
    'lastServiceByCategory': lastServiceByCategory.map(
      (k, v) => MapEntry(k, v.toIso8601String()),
    ),
    'propertyInfo': propertyInfo?.toJson(),
  };

  factory HomeHealthModel.fromJson(Map<String, dynamic> json) {
    return HomeHealthModel(
      userId: json['userId'] as String,
      totalSpending: (json['totalSpending'] as num?)?.toDouble() ?? 0,
      monthlySpending:
          (json['monthlySpending'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      categorySpending:
          (json['categorySpending'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      totalServices: json['totalServices'] as int? ?? 0,
      servicesByCategory:
          (json['servicesByCategory'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
          {},
      upcomingReminders:
          (json['upcomingReminders'] as List<dynamic>?)
              ?.map(
                (r) => MaintenanceReminder.fromJson(r as Map<String, dynamic>),
              )
              .toList() ??
          [],
      lastServiceByCategory:
          (json['lastServiceByCategory'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, DateTime.parse(v as String)),
          ) ??
          {},
      propertyInfo: json['propertyInfo'] != null
          ? PropertyInfo.fromJson(json['propertyInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    totalSpending,
    monthlySpending,
    categorySpending,
    totalServices,
    servicesByCategory,
    upcomingReminders,
    lastServiceByCategory,
    propertyInfo,
  ];
}

/// Maintenance reminder model
class MaintenanceReminder extends Equatable {
  final String id;
  final String title;
  final String category;
  final DateTime dueDate;
  final String? description;
  final bool isCompleted;
  final int intervalMonths;

  const MaintenanceReminder({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    this.description,
    this.isCompleted = false,
    this.intervalMonths = 12,
  });

  bool get isOverdue => !isCompleted && DateTime.now().isAfter(dueDate);

  bool get isDueSoon =>
      !isCompleted &&
      dueDate.difference(DateTime.now()).inDays <= 14 &&
      !isOverdue;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'dueDate': dueDate.toIso8601String(),
    'description': description,
    'isCompleted': isCompleted,
    'intervalMonths': intervalMonths,
  };

  factory MaintenanceReminder.fromJson(Map<String, dynamic> json) {
    return MaintenanceReminder(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      intervalMonths: json['intervalMonths'] as int? ?? 12,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    dueDate,
    description,
    isCompleted,
    intervalMonths,
  ];
}

/// Property information model
class PropertyInfo extends Equatable {
  final String? type; // apartment, villa, office, etc.
  final int? yearBuilt;
  final double? sizeSquareMeters;
  final int? numberOfRooms;
  final int? numberOfBathrooms;
  final String? address;

  const PropertyInfo({
    this.type,
    this.yearBuilt,
    this.sizeSquareMeters,
    this.numberOfRooms,
    this.numberOfBathrooms,
    this.address,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'yearBuilt': yearBuilt,
    'sizeSquareMeters': sizeSquareMeters,
    'numberOfRooms': numberOfRooms,
    'numberOfBathrooms': numberOfBathrooms,
    'address': address,
  };

  factory PropertyInfo.fromJson(Map<String, dynamic> json) {
    return PropertyInfo(
      type: json['type'] as String?,
      yearBuilt: json['yearBuilt'] as int?,
      sizeSquareMeters: (json['sizeSquareMeters'] as num?)?.toDouble(),
      numberOfRooms: json['numberOfRooms'] as int?,
      numberOfBathrooms: json['numberOfBathrooms'] as int?,
      address: json['address'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    type,
    yearBuilt,
    sizeSquareMeters,
    numberOfRooms,
    numberOfBathrooms,
    address,
  ];
}

/// Common maintenance items with recommended intervals
class MaintenanceSchedule {
  static const Map<String, int> recommendedIntervals = {
    'AC Service': 6,
    'Plumbing Inspection': 12,
    'Electrical Inspection': 12,
    'Water Heater Service': 12,
    'Pest Control': 3,
    'Deep Cleaning': 6,
    'Paint Touch-up': 24,
    'Appliance Check': 12,
  };

  static List<String> get allItems => recommendedIntervals.keys.toList();
}
