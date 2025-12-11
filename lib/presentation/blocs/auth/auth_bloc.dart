// File: lib/presentation/blocs/auth/auth_bloc.dart
// Purpose: BLoC for handling authentication logic using Clean Architecture Use Cases

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:home_repair_app/core/usecases/usecase.dart';
import 'package:home_repair_app/domain/entities/user_entity.dart';
import 'package:home_repair_app/domain/repositories/i_auth_repository.dart';
import 'package:home_repair_app/domain/repositories/i_user_repository.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_in_with_email.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_up_with_email.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_in_with_google.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_in_with_facebook.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_out.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc using Clean Architecture Use Cases.
///
/// This BLoC delegates business logic to use cases instead of
/// calling repositories directly, following Uncle Bob's Clean Architecture.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Use Cases
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final SignInWithFacebook _signInWithFacebook;
  final SignOut _signOut;

  // Repositories (needed for auth state stream and role updates)
  final IAuthRepository _authRepository;
  final IUserRepository _userRepository;

  StreamSubscription<UserEntity?>? _authStateSubscription;

  AuthBloc({
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required SignInWithFacebook signInWithFacebook,
    required SignOut signOut,
    required IAuthRepository authRepository,
    required IUserRepository userRepository,
  }) : _signInWithEmail = signInWithEmail,
       _signUpWithEmail = signUpWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _signInWithFacebook = signInWithFacebook,
       _signOut = signOut,
       _authRepository = authRepository,
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

    // Listen to auth state changes
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

    final result = await _signInWithEmail(
      SignInParams(email: event.email, password: event.password),
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

    final result = await _signUpWithEmail(
      SignUpParams(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
      ),
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

    final result = await _signInWithGoogle(const NoParams());

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

    final result = await _signInWithFacebook(const NoParams());

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
    final result = await _signOut(const NoParams());

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
      final result = await _userRepository.getUser(event.userId);
      result.fold(
        (failure) {
          emit(AuthError('Failed to update role: ${failure.message}'));
        },
        (userEntity) {
          if (!isClosed && userEntity != null) {
            add(AuthUserChanged(userEntity));
          }
        },
      );
    } catch (e) {
      debugPrint('Error updating role: $e');
      emit(AuthError('Failed to update role: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
