// File: lib/blocs/auth/auth_event.dart
// Purpose: Define authentication events for AuthBloc

import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;

  const AuthSignupRequested({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [email, password, fullName, phoneNumber];
}

class AuthGoogleSignInRequested extends AuthEvent {
  const AuthGoogleSignInRequested();
}

class AuthFacebookSignInRequested extends AuthEvent {
  const AuthFacebookSignInRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthUserChanged extends AuthEvent {
  final UserModel? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthRoleUpdateRequested extends AuthEvent {
  final String userId;
  final UserRole newRole;

  const AuthRoleUpdateRequested({required this.userId, required this.newRole});

  @override
  List<Object?> get props => [userId, newRole];
}
