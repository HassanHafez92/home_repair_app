// File: test/auth_bloc_test.dart
// Purpose: Unit tests for AuthBloc

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_repair_app/blocs/auth/auth_bloc.dart';
import 'package:home_repair_app/blocs/auth/auth_event.dart';
import 'package:home_repair_app/blocs/auth/auth_state.dart';
import 'package:home_repair_app/domain/repositories/i_auth_repository.dart';
import 'package:home_repair_app/domain/repositories/i_user_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// Generate mocks
@GenerateNiceMocks([
  MockSpec<IAuthRepository>(),
  MockSpec<IUserRepository>(),
  MockSpec<firebase_auth.User>(),
  MockSpec<firebase_auth.UserCredential>(),
])
import 'auth_bloc_test.mocks.dart';

void main() {
  group('AuthBloc', () {
    late IAuthRepository mockAuthRepository;
    late IUserRepository mockUserRepository;
    late AuthBloc authBloc;

    setUp(() {
      mockAuthRepository = MockIAuthRepository();
      mockUserRepository = MockIUserRepository();

      // Setup default stream behavior
      when(
        mockAuthRepository.authStateChanges,
      ).thenAnswer((_) => Stream.empty());

      authBloc = AuthBloc(
        authRepository: mockAuthRepository,
        userRepository: mockUserRepository,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthUnauthenticated', () {
      expect(authBloc.state, const AuthUnauthenticated());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when login fails',
      setUp: () {
        when(
          mockAuthRepository.signInWithEmail(
            email: 'test@test.com',
            password: 'password',
          ),
        ).thenThrow(Exception('Login failed'));
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'test@test.com', password: 'password'),
      ),
      expect: () => [
        const AuthLoading(),
        isA<AuthError>(),
        const AuthUnauthenticated(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading] when login succeeds (user loaded via stream)',
      setUp: () {
        when(
          mockAuthRepository.signInWithEmail(
            email: 'test@test.com',
            password: 'password',
          ),
        ).thenAnswer((_) async => MockUserCredential());
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(
        const AuthLoginRequested(email: 'test@test.com', password: 'password'),
      ),
      expect: () => [const AuthLoading()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [] when logout requested (state handled by auth stream)',
      setUp: () {
        when(mockAuthRepository.signOut()).thenAnswer((_) async {});
      },
      build: () => authBloc,
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      expect: () => [],
    );
  });
}
