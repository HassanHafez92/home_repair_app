// File: test/auth_bloc_test.dart
// Purpose: Unit tests for AuthBloc with Use Cases (Clean Architecture)

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_repair_app/core/error/failures.dart';

import 'package:home_repair_app/domain/entities/user_entity.dart';
import 'package:home_repair_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:home_repair_app/presentation/blocs/auth/auth_event.dart';
import 'package:home_repair_app/presentation/blocs/auth/auth_state.dart';
import 'package:home_repair_app/domain/repositories/i_auth_repository.dart';
import 'package:home_repair_app/domain/repositories/i_user_repository.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_in_with_email.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_up_with_email.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_in_with_google.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_in_with_facebook.dart';
import 'package:home_repair_app/domain/usecases/auth/sign_out.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks
@GenerateNiceMocks([
  MockSpec<IAuthRepository>(),
  MockSpec<IUserRepository>(),
  MockSpec<SignInWithEmail>(),
  MockSpec<SignUpWithEmail>(),
  MockSpec<SignInWithGoogle>(),
  MockSpec<SignInWithFacebook>(),
  MockSpec<SignOut>(),
])
import 'auth_bloc_test.mocks.dart';

// Test fixture
UserEntity createTestUser({
  String id = 'test-uid',
  String email = 'test@test.com',
  String fullName = 'Test User',
}) {
  return UserEntity(
    id: id,
    email: email,
    fullName: fullName,
    role: UserRole.customer,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
    lastActive: DateTime(2024, 1, 1),
    emailVerified: true,
  );
}

void main() {
  group('AuthBloc', () {
    late MockIAuthRepository mockAuthRepository;
    late MockIUserRepository mockUserRepository;
    late MockSignInWithEmail mockSignInWithEmail;
    late MockSignUpWithEmail mockSignUpWithEmail;
    late MockSignInWithGoogle mockSignInWithGoogle;
    late MockSignInWithFacebook mockSignInWithFacebook;
    late MockSignOut mockSignOut;

    AuthBloc createAuthBloc() {
      return AuthBloc(
        signInWithEmail: mockSignInWithEmail,
        signUpWithEmail: mockSignUpWithEmail,
        signInWithGoogle: mockSignInWithGoogle,
        signInWithFacebook: mockSignInWithFacebook,
        signOut: mockSignOut,
        authRepository: mockAuthRepository,
        userRepository: mockUserRepository,
      );
    }

    setUp(() {
      mockAuthRepository = MockIAuthRepository();
      mockUserRepository = MockIUserRepository();
      mockSignInWithEmail = MockSignInWithEmail();
      mockSignUpWithEmail = MockSignUpWithEmail();
      mockSignInWithGoogle = MockSignInWithGoogle();
      mockSignInWithFacebook = MockSignInWithFacebook();
      mockSignOut = MockSignOut();

      // Setup default stream behavior
      when(
        mockAuthRepository.authStateChanges,
      ).thenAnswer((_) => Stream<UserEntity?>.empty());

      // Setup default currentUser
      when(mockAuthRepository.currentUser).thenReturn(null);
    });

    test(
      'initial state transitions to AuthUnauthenticated when no user',
      () async {
        final authBloc = createAuthBloc();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(authBloc.state, const AuthUnauthenticated());
        await authBloc.close();
      },
    );

    group('login', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError, AuthUnauthenticated] when login fails',
        setUp: () {
          when(
            mockSignInWithEmail(any),
          ).thenAnswer((_) async => const Left(AuthFailure('Login failed')));
        },
        build: createAuthBloc,
        act: (bloc) => bloc.add(
          const AuthLoginRequested(
            email: 'test@test.com',
            password: 'password',
          ),
        ),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>().having((e) => e.message, 'message', 'Login failed'),
          const AuthUnauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when login succeeds',
        setUp: () {
          final testUser = createTestUser();
          when(
            mockSignInWithEmail(any),
          ).thenAnswer((_) async => Right(testUser));
        },
        build: createAuthBloc,
        act: (bloc) => bloc.add(
          const AuthLoginRequested(
            email: 'test@test.com',
            password: 'password',
          ),
        ),
        expect: () => [const AuthLoading(), isA<AuthAuthenticated>()],
      );
    });

    group('logout', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when logout succeeds',
        setUp: () {
          when(mockSignOut(any)).thenAnswer((_) async => const Right(null));
        },
        build: createAuthBloc,
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [const AuthUnauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] even when logout fails',
        setUp: () {
          when(
            mockSignOut(any),
          ).thenAnswer((_) async => const Left(AuthFailure('Logout error')));
        },
        build: createAuthBloc,
        act: (bloc) => bloc.add(const AuthLogoutRequested()),
        expect: () => [const AuthUnauthenticated()],
      );
    });

    group('Google sign in', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError, AuthUnauthenticated] when fails',
        setUp: () {
          when(mockSignInWithGoogle(any)).thenAnswer(
            (_) async => const Left(AuthFailure('Google sign in failed')),
          );
        },
        build: createAuthBloc,
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>(),
          const AuthUnauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when succeeds',
        setUp: () {
          final testUser = createTestUser();
          when(
            mockSignInWithGoogle(any),
          ).thenAnswer((_) async => Right(testUser));
        },
        build: createAuthBloc,
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [const AuthLoading(), isA<AuthAuthenticated>()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError, AuthUnauthenticated] when cancelled',
        setUp: () {
          when(
            mockSignInWithGoogle(any),
          ).thenAnswer((_) async => const Right(null));
        },
        build: createAuthBloc,
        act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>(),
          const AuthUnauthenticated(),
        ],
      );
    });
  });
}
