// File: lib/blocs/booking/booking_state.dart
// Purpose: Define states for BookingBloc

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';

enum BookingStatus { initial, filling, submitting, success, failure }

class BookingState extends Equatable {
  final BookingStatus status;
  final int currentStep;
  final ServiceEntity? service;
  final String description;
  final String address;
  final double? latitude;
  final double? longitude;
  final DateTime? scheduledDate;
  final TimeOfDay? scheduledTime;
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
    this.errorMessage,
    this.orderId,
  });

  bool get isStep1Valid => description.isNotEmpty;
  bool get isStep2Valid =>
      address.isNotEmpty && scheduledDate != null && scheduledTime != null;

  BookingState copyWith({
    BookingStatus? status,
    int? currentStep,
    ServiceEntity? service,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
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
    errorMessage,
    orderId,
  ];
}
