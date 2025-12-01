// File: lib/blocs/booking/booking_state.dart
// Purpose: Define states for BookingBloc

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../models/service_model.dart';

enum BookingStatus { initial, filling, submitting, success, failure }

class BookingState extends Equatable {
  final BookingStatus status;
  final int currentStep;
  final ServiceModel? service;
  final String description;
  final String address;
  final double? latitude;
  final double? longitude;
  final DateTime? scheduledDate;
  final TimeOfDay? scheduledTime;
  final String paymentMethod;
  final String? errorMessage;
  final String? orderId;

  const BookingState({
    this.status = BookingStatus.initial,
    this.currentStep = 0,
    this.service,
    this.description = '',
    this.address = '',
    this.latitude,
    this.longitude,
    this.scheduledDate,
    this.scheduledTime,
    this.paymentMethod = 'cash',
    this.errorMessage,
    this.orderId,
  });

  bool get isStep1Valid => description.isNotEmpty;
  bool get isStep2Valid =>
      address.isNotEmpty && scheduledDate != null && scheduledTime != null;
  bool get isStep3Valid => true; // Payment method always has a default

  BookingState copyWith({
    BookingStatus? status,
    int? currentStep,
    ServiceModel? service,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
    String? paymentMethod,
    String? errorMessage,
    String? orderId,
  }) {
    return BookingState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      service: service ?? this.service,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      errorMessage: errorMessage ?? this.errorMessage,
      orderId: orderId ?? this.orderId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentStep,
    service,
    description,
    address,
    latitude,
    longitude,
    scheduledDate,
    scheduledTime,
    paymentMethod,
    errorMessage,
    orderId,
  ];
}
