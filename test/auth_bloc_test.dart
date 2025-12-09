// File: test/auth_bloc_test.dart
// Purpose: Unit tests for AuthBloc

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
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks
@GenerateNiceMocks([MockSpec<IAuthRepository>(), MockSpec<IUserRepository>()])
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
    late AuthBloc authBloc;

    setUp(() {
      mockAuthRepository = MockIAuthRepository();
      mockUserRepository = MockIUserRepository();

      // Setup default stream behavior - returns UserEntity? now
      when(
        mockAuthRepository.authStateChanges,
      ).thenAnswer((_) => Stream<UserEntity?>.empty());

      // Setup default currentUser
      when(mockAuthRepository.currentUser).thenReturn(null);

      authBloc = AuthBloc(
        authRepository: mockAuthRepository,
        userRepository: mockUserRepository,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test(
      'initial state transitions to AuthUnauthenticated when no user',
      () async {
        // Give the bloc time to process the initial state
        await Future.delayed(const Duration(milliseconds: 100));
        expect(authBloc.state, const AuthUnauthenticated());
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError, AuthUnauthenticated] when login fails',
      setUp: () {
        when(
          mockAuthRepository.signInWithEmail(
            email: 'test@test.com',
            password: 'password',
          ),
        ).thenAnswer((_) async => const Left(AuthFailure('Login failed')));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'test@test.com', password: 'password'),
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
          mockAuthRepository.signInWithEmail(
            email: 'test@test.com',
            password: 'password',
          ),
        ).thenAnswer((_) async => Right(testUser));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'test@test.com', password: 'password'),
      ),
      expect: () => [const AuthLoading(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when logout succeeds',
      setUp: () {
        when(
          mockAuthRepository.signOut(),
        ).thenAnswer((_) async => const Right(null));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] even when logout fails',
      setUp: () {
        when(
          mockAuthRepository.signOut(),
        ).thenAnswer((_) async => const Left(AuthFailure('Logout error')));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [const AuthUnauthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError, AuthUnauthenticated] when Google sign in fails',
      setUp: () {
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => const Left(AuthFailure('Google sign in failed')),
        );
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when Google sign in succeeds',
      setUp: () {
        final testUser = createTestUser();
        when(
          mockAuthRepository.signInWithGoogle(),
        ).thenAnswer((_) async => Right(testUser));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [const AuthLoading(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError, AuthUnauthenticated] when Google sign in is cancelled',
      setUp: () {
        when(
          mockAuthRepository.signInWithGoogle(),
        ).thenAnswer((_) async => const Right(null));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const AuthGoogleSignInRequested()),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
        const AuthUnauthenticated(),
      ],
    );
  });
}
