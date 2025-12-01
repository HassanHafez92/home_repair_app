// File: lib/blocs/auth/auth_bloc.dart
// Purpose: BLoC for handling authentication logic

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../../models/customer_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final IAuthRepository _authRepository;
  final IUserRepository _userRepository;
  StreamSubscription<User?>? _authStateSubscription;

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

    // Listen to Firebase auth state changes
    _authStateSubscription = _authRepository.authStateChanges.listen((
      firebaseUser,
    ) {
      if (firebaseUser != null) {
        _loadUserData(firebaseUser.uid);
      } else {
        add(const AuthUserChanged(null));
      }
    });

    // Check current user immediately to avoid stuck state
    final currentUser = _authRepository.currentUser;
    if (currentUser == null) {
      add(const AuthUserChanged(null));
    } else {
      _loadUserData(currentUser.uid);
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final user = await _userRepository.getUser(uid);
      if (!isClosed) add(AuthUserChanged(user));
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (!isClosed) add(const AuthUserChanged(null));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      // User data will be loaded via auth state listener
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // 1. Create Auth User
      final credential = await _authRepository.signUpWithEmail(
        email: event.email,
        password: event.password,
      );

      if (credential.user != null) {
        // 2. Create Firestore User Document
        final newCustomer = CustomerModel(
          id: credential.user!.uid,
          email: event.email,
          fullName: event.fullName,
          phoneNumber: event.phoneNumber,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          lastActive: DateTime.now(),
        );

        await _userRepository.createUser(newCustomer);
        // User data will be loaded via auth state listener
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final credential = await _authRepository.signInWithGoogle();
      if (credential == null) {
        emit(const AuthError('Google sign in was cancelled'));
        emit(const AuthUnauthenticated());
      }
      // User data will be loaded via auth state listener if successful
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onFacebookSignInRequested(
    AuthFacebookSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final credential = await _authRepository.signInWithFacebook();
      if (credential == null) {
        emit(const AuthError('Facebook sign in was cancelled'));
        emit(const AuthUnauthenticated());
      }
      // User data will be loaded via auth state listener if successful
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Still emit unauthenticated even if logout fails
      emit(const AuthUnauthenticated());
    }
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
      await _loadUserData(event.userId);
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
