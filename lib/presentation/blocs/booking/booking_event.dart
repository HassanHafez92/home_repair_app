// File: lib/blocs/booking/booking_event.dart
// Purpose: Define events for BookingBloc

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import 'package:home_repair_app/models/media_file_model.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingStarted extends BookingEvent {
  final ServiceEntity service;
  const BookingStarted(this.service);
  @override
  List<Object?> get props => [service];
}

class BookingStepChanged extends BookingEvent {
  final int step;
  const BookingStepChanged(this.step);
  @override
  List<Object?> get props => [step];
}

class BookingDescriptionChanged extends BookingEvent {
  final String description;
  const BookingDescriptionChanged(this.description);
  @override
  List<Object?> get props => [description];
}

class BookingMediaAdded extends BookingEvent {
  final MediaFileModel media;
  const BookingMediaAdded(this.media);
  @override
  List<Object?> get props => [media];
}

class BookingMediaRemoved extends BookingEvent {
  final String mediaId;
  const BookingMediaRemoved(this.mediaId);
  @override
  List<Object?> get props => [mediaId];
}

class BookingLocationChanged extends BookingEvent {
  final String address;
  final double? latitude;
  final double? longitude;

  const BookingLocationChanged(this.address, {this.latitude, this.longitude});

  @override
  List<Object?> get props => [address, latitude, longitude];
}

class BookingScheduleChanged extends BookingEvent {
  final DateTime? date;
  final TimeOfDay? time;
  const BookingScheduleChanged({this.date, this.time});
  @override
  List<Object?> get props => [date, time];
}

class BookingSubmitted extends BookingEvent {
  final String userId;
  const BookingSubmitted(this.userId);
  @override
  List<Object?> get props => [userId];
}
