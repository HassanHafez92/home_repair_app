// File: lib/presentation/blocs/auth/auth_bloc.dart
// Purpose: BLoC for handling authentication logic using Clean Architecture

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:home_repair_app/domain/entities/user_entity.dart';
import 'package:home_repair_app/domain/repositories/i_auth_repository.dart';
import 'package:home_repair_app/domain/repositories/i_user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _authRepository;
  final IUserRepository _userRepository;
  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required IAuthRepository authRepository,
    required IUserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       super(const AuthInitial()) {
    // Register event handlers
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthFacebookSignInRequested>(_onFacebookSignInRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthRoleUpdateRequested>(_onRoleUpdateRequested);

    // Listen to auth state changes (stream now returns UserEntity?)
    _authStateSubscription = _authRepository.authStateChanges.listen((
      userEntity,
    ) {
      if (!isClosed) {
        add(AuthUserChanged(userEntity));
      }
    });

    // Check current user immediately to avoid stuck state
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      add(const AuthUserChanged(null));
    } else {
      add(AuthUserChanged(currentUser));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signInWithEmail(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) {
        emit(AuthError(failure.message));
        emit(const AuthUnauthenticated());
      },
      (user) {
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signUpWithEmail(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
      phoneNumber: event.phoneNumber,
    );

    result.fold(
      (failure) {
        emit(AuthError(failure.message));
        emit(const AuthUnauthenticated());
      },
      (user) {
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signInWithGoogle();

    result.fold(
      (failure) {
        emit(AuthError(failure.message));
        emit(const AuthUnauthenticated());
      },
      (user) {
        if (user == null) {
          emit(const AuthError('Google sign in was cancelled'));
          emit(const AuthUnauthenticated());
        } else {
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  Future<void> _onFacebookSignInRequested(
    AuthFacebookSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.signInWithFacebook();

    result.fold(
      (failure) {
        emit(AuthError(failure.message));
        emit(const AuthUnauthenticated());
      },
      (user) {
        if (user == null) {
          emit(const AuthError('Facebook sign in was cancelled'));
          emit(const AuthUnauthenticated());
        } else {
          emit(AuthAuthenticated(user));
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.signOut();

    result.fold(
      (failure) {
        debugPrint('Error during logout: ${failure.message}');
        // Still emit unauthenticated even if logout fails
        emit(const AuthUnauthenticated());
      },
      (_) {
        emit(const AuthUnauthenticated());
      },
    );
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onRoleUpdateRequested(
    AuthRoleUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _userRepository.updateUserFields(event.userId, {
        'role': event.newRole.name,
      });
      // Reload user data to reflect the change
      final user = await _userRepository.getUser(event.userId);
      if (!isClosed) {
        add(AuthUserChanged(_mapUserModelToEntity(user)));
      }
    } catch (e) {
      debugPrint('Error updating role: $e');
      emit(AuthError('Failed to update role: ${e.toString()}'));
    }
  }

  /// Helper to convert UserModel to UserEntity for backwards compatibility
  UserEntity? _mapUserModelToEntity(dynamic user) {
    if (user == null) return null;
    // The user from IUserRepository is still UserModel, need to convert
    return UserEntity(
      id: user.id,
      email: user.email,
      phoneNumber: user.phoneNumber,
      fullName: user.fullName,
      profilePhoto: user.profilePhoto,
      role: _mapRole(user.role),
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastActive: user.lastActive,
      emailVerified: user.emailVerified,
    );
  }

  UserRole _mapRole(dynamic role) {
    if (role == null) return UserRole.customer;
    if (role is UserRole) return role;
    // Handle string role from UserModel
    final roleName = role.toString().split('.').last;
    switch (roleName) {
      case 'admin':
        return UserRole.admin;
      case 'technician':
        return UserRole.technician;
      default:
        return UserRole.customer;
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
