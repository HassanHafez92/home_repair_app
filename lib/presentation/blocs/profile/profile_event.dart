// File: lib/blocs/profile/profile_event.dart
// Purpose: Events for ProfileBloc

import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileUpdateRequested extends ProfileEvent {
  final String fullName;
  final String phoneNumber;

  const ProfileUpdateRequested({
    required this.fullName,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [fullName, phoneNumber];
}

class ProfileImageUpdateRequested extends ProfileEvent {
  final File imageFile;

  const ProfileImageUpdateRequested(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}



