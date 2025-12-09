// File: lib/blocs/profile/profile_bloc.dart
// Purpose: BLoC for handling user profile logic

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_repair_app/domain/repositories/i_auth_repository.dart';
import 'package:home_repair_app/domain/repositories/i_user_repository.dart';
import 'package:home_repair_app/services/storage_service.dart';
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

    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'User not logged in',
        ),
      );
      return;
    }

    final result = await _userRepository.getUser(currentUser.id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(state.copyWith(status: ProfileStatus.success, user: user)),
    );
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.user == null) return;

    emit(state.copyWith(status: ProfileStatus.loading));

    // Update Firestore
    final updates = {
      'fullName': event.fullName,
      'phoneNumber': event.phoneNumber,
    };

    final updateResult = await _userRepository.updateUserFields(
      state.user!.id,
      updates,
    );

    await updateResult.fold(
      (failure) async => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) async {
        // Reload user to get fresh data
        final userResult = await _userRepository.getUser(state.user!.id);
        userResult.fold(
          (failure) => emit(
            state.copyWith(
              status: ProfileStatus.failure,
              errorMessage: failure.message,
            ),
          ),
          (user) =>
              emit(state.copyWith(status: ProfileStatus.success, user: user)),
        );
      },
    );
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
      final updateResult = await _userRepository.updateUserFields(
        state.user!.id,
        updates,
      );

      await updateResult.fold(
        (failure) async => emit(
          state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (_) async {
          // Reload user
          final userResult = await _userRepository.getUser(state.user!.id);
          userResult.fold(
            (failure) => emit(
              state.copyWith(
                status: ProfileStatus.failure,
                errorMessage: failure.message,
              ),
            ),
            (user) =>
                emit(state.copyWith(status: ProfileStatus.success, user: user)),
          );
        },
      );
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
