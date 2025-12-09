// File: lib/presentation/blocs/auth/auth_state.dart
// Purpose: Define authentication states for AuthBloc

import 'package:equatable/equatable.dart';
import 'package:home_repair_app/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];

  // Helper getters
  UserRole get userRole => user.role;
  String get userId => user.id;
  String get userEmail => user.email;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
