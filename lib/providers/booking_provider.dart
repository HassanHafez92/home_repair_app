// File: lib/providers/booking_provider.dart
// Purpose: Manage state for the multi-step booking wizard.

import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../models/payment_model.dart';

class BookingProvider with ChangeNotifier {
  ServiceModel? _selectedService;
  String? _description;
  String? _address;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  // Getters
  ServiceModel? get selectedService => _selectedService;
  String? get description => _description;
  String? get address => _address;
  DateTime? get scheduledDate => _scheduledDate;
  TimeOfDay? get scheduledTime => _scheduledTime;
  PaymentMethod get paymentMethod => _paymentMethod;

  bool get isStep1Valid => _description != null && _description!.isNotEmpty;
  bool get isStep2Valid =>
      _address != null &&
      _address!.isNotEmpty &&
      _scheduledDate != null &&
      _scheduledTime != null;

  // Setters
  void selectService(ServiceModel service) {
    _selectedService = service;
    notifyListeners();
  }

  void updateDescription(String desc) {
    _description = desc;
    notifyListeners();
  }

  void updateLocation(String addr) {
    _address = addr;
    notifyListeners();
  }

  void updateSchedule(DateTime date, TimeOfDay time) {
    _scheduledDate = date;
    _scheduledTime = time;
    notifyListeners();
  }

  void updatePaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void clearBooking() {
    _selectedService = null;
    _description = null;
    _address = null;
    _scheduledDate = null;
    _scheduledTime = null;
    _paymentMethod = PaymentMethod.cash;
    notifyListeners();
  }

  // Helper to combine date and time
  DateTime? get fullScheduledDateTime {
    if (_scheduledDate == null || _scheduledTime == null) return null;
    return DateTime(
      _scheduledDate!.year,
      _scheduledDate!.month,
      _scheduledDate!.day,
      _scheduledTime!.hour,
      _scheduledTime!.minute,
    );
  }
}
