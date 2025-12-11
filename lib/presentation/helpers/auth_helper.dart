// Auth helper extensions for easy access to authenticated user data.
//
// Provides convenient BuildContext extensions to access AuthBloc state
// without needing to manually check state types everywhere.

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../../domain/entities/user_entity.dart';

/// Extension on [BuildContext] for easy authentication state access.
extension AuthContextExtension on BuildContext {
  /// Gets the current [AuthBloc] instance.
  AuthBloc get authBloc => read<AuthBloc>();

  /// Gets the current [AuthState].
  AuthState get authState => authBloc.state;

  /// Returns `true` if the user is currently authenticated.
  bool get isAuthenticated => authState is AuthAuthenticated;

  /// Gets the authenticated user data, or `null` if not authenticated.
  UserEntity? get currentUser {
    final state = authState;
    return state is AuthAuthenticated ? state.user : null;
  }

  /// Gets the current user's ID, or `null` if not authenticated.
  String? get userId {
    final state = authState;
    return state is AuthAuthenticated ? state.userId : null;
  }

  /// Gets the current user's role, or `null` if not authenticated.
  UserRole? get userRole {
    final state = authState;
    return state is AuthAuthenticated ? state.userRole : null;
  }

  /// Gets the current user's email, or `null` if not authenticated.
  String? get userEmail {
    final state = authState;
    return state is AuthAuthenticated ? state.userEmail : null;
  }

  /// Requires the user to be authenticated, throwing if not.
  ///
  /// Use this when you're sure the user must be authenticated at this point.
  /// Throws [StateError] if not authenticated.
  String get requireUserId {
    final id = userId;
    if (id == null) {
      throw StateError('User must be authenticated to access userId');
    }
    return id;
  }

  /// Requires the authenticated user, throwing if not authenticated.
  UserEntity get requireCurrentUser {
    final user = currentUser;
    if (user == null) {
      throw StateError('User must be authenticated');
    }
    return user;
  }
}
