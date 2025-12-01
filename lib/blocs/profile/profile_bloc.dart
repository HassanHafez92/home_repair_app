// File: lib/blocs/profile/profile_bloc.dart
// Purpose: BLoC for handling user profile logic

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../services/storage_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IAuthRepository _authRepository;
  final IUserRepository _userRepository;
  final StorageService _storageService;

  ProfileBloc({
    required IAuthRepository authRepository,
    required IUserRepository userRepository,
    required StorageService storageService,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _storageService = storageService,
       super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileImageUpdateRequested>(_onImageUpdateRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final currentUser = _authRepository.currentUser;
      if (currentUser != null) {
        final user = await _userRepository.getUser(currentUser.uid);
        emit(state.copyWith(status: ProfileStatus.success, user: user));
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: 'User not logged in',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.user == null) return;

    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      // Update Auth Display Name
      await _authRepository.currentUser?.updateDisplayName(event.fullName);

      // Update Firestore
      final updates = {
        'fullName': event.fullName,
        'phoneNumber': event.phoneNumber,
      };
      await _userRepository.updateUserFields(state.user!.id, updates);

      // Reload user to get fresh data
      final updatedUser = await _userRepository.getUser(state.user!.id);
      emit(state.copyWith(status: ProfileStatus.success, user: updatedUser));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onImageUpdateRequested(
    ProfileImageUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.user == null) return;

    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final imageUrl = await _storageService.uploadProfilePicture(
        state.user!.id,
        event.imageFile,
      );

      final updates = {'profilePictureUrl': imageUrl};
      await _userRepository.updateUserFields(state.user!.id, updates);

      // Reload user
      final updatedUser = await _userRepository.getUser(state.user!.id);
      emit(state.copyWith(status: ProfileStatus.success, user: updatedUser));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
