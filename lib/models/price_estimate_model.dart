// File: lib/models/price_estimate_model.dart
// Purpose: Model for calculating and displaying price estimates with inspection fee.

import 'package:equatable/equatable.dart';
import 'service_addon_model.dart';

/// Price estimate model that implements the 50 EGP inspection fee model.
/// The inspection fee is paid upfront and deducted from the final service cost.
class PriceEstimateModel extends Equatable {
  /// Base price for the service (from technician after inspection)
  final double basePrice;

  /// Minimum expected price for the service
  final double minPrice;

  /// Maximum expected price for the service
  final double maxPrice;

  /// Inspection fee (50 EGP) - paid upfront, deducted from total
  final double inspectionFee;

  /// List of selected add-ons
  final List<ServiceAddOnModel> selectedAddOns;

  /// VAT percentage (14% in Egypt)
  final double vatPercentage;

  /// Optional discount amount
  final double? discountAmount;

  /// Optional discount code applied
  final String? discountCode;

  const PriceEstimateModel({
    required this.basePrice,
    required this.minPrice,
    required this.maxPrice,
    this.inspectionFee = 50.0, // Default 50 EGP
    this.selectedAddOns = const [],
    this.vatPercentage = 0.14, // 14% VAT in Egypt
    this.discountAmount,
    this.discountCode,
  });

  /// Calculate total add-ons price
  double get addOnsTotal =>
      selectedAddOns.fold(0.0, (sum, addon) => sum + addon.price);

  /// Calculate subtotal before VAT (base + add-ons)
  double get subtotal => basePrice + addOnsTotal;

  /// Calculate VAT amount
  double get vatAmount => subtotal * vatPercentage;

  /// Calculate total before inspection fee deduction
  double get totalBeforeDeduction =>
      subtotal + vatAmount - (discountAmount ?? 0);

  /// Calculate final amount due after inspection fee deduction
  /// This is what the customer pays at service completion
  double get amountDueAfterInspection =>
      (totalBeforeDeduction - inspectionFee).clamp(0, double.infinity);

  /// Get the price range string for display
  String get priceRangeDisplay =>
      '${minPrice.toInt()} - ${maxPrice.toInt()} EGP';

  /// Check if the estimate uses the average (before inspection)
  bool get isEstimateOnly => basePrice == 0;

  /// Create an estimate using average price (before inspection)
  factory PriceEstimateModel.estimate({
    required double minPrice,
    required double maxPrice,
    double inspectionFee = 50.0,
    List<ServiceAddOnModel> selectedAddOns = const [],
    double vatPercentage = 0.14,
  }) {
    return PriceEstimateModel(
      basePrice: (minPrice + maxPrice) / 2, // Use average as estimate
      minPrice: minPrice,
      maxPrice: maxPrice,
      inspectionFee: inspectionFee,
      selectedAddOns: selectedAddOns,
      vatPercentage: vatPercentage,
    );
  }

  /// Create a final quote after inspection
  factory PriceEstimateModel.finalQuote({
    required double actualPrice,
    required double minPrice,
    required double maxPrice,
    double inspectionFee = 50.0,
    List<ServiceAddOnModel> selectedAddOns = const [],
    double vatPercentage = 0.14,
    double? discountAmount,
    String? discountCode,
  }) {
    return PriceEstimateModel(
      basePrice: actualPrice,
      minPrice: minPrice,
      maxPrice: maxPrice,
      inspectionFee: inspectionFee,
      selectedAddOns: selectedAddOns,
      vatPercentage: vatPercentage,
      discountAmount: discountAmount,
      discountCode: discountCode,
    );
  }

  /// Create a copy with updated values
  PriceEstimateModel copyWith({
    double? basePrice,
    double? minPrice,
    double? maxPrice,
    double? inspectionFee,
    List<ServiceAddOnModel>? selectedAddOns,
    double? vatPercentage,
    double? discountAmount,
    String? discountCode,
  }) {
    return PriceEstimateModel(
      basePrice: basePrice ?? this.basePrice,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inspectionFee: inspectionFee ?? this.inspectionFee,
      selectedAddOns: selectedAddOns ?? this.selectedAddOns,
      vatPercentage: vatPercentage ?? this.vatPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      discountCode: discountCode ?? this.discountCode,
    );
  }

  @override
  List<Object?> get props => [
    basePrice,
    minPrice,
    maxPrice,
    inspectionFee,
    selectedAddOns,
    vatPercentage,
    discountAmount,
    discountCode,
  ];
}
