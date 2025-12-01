# Testing Guide

Comprehensive guide for writing and running tests in the Home Repair App.

## Table of Contents
- [Testing Strategy](#testing-strategy)
- [Running Tests](#running-tests)
- [Unit Testing](#unit-testing)
- [Widget Testing](#widget-testing)
- [Integration Testing](#integration-testing)
- [Mocking](#mocking)
- [Coverage](#coverage)

---

## Testing Strategy

### Test Pyramid

```
        /\
       /  \     E2E/Integration Tests (Few)
      /____\
     /      \   Widget Tests (Some)
    /________\
   /          \ Unit Tests (Many)
  /__________
\
```

**Distribution**:
- **70%** Unit Tests (BLoCs, services, models, utilities)
- **20%** Widget Tests (UI components, screens)
- **10%** Integration Tests (Complete user flows)

---

## Running Tests

### All Tests
```bash
flutter test
```

### Specific Test File
```bash
flutter test test/unit/blocs/auth_bloc_test.dart
```

### With Coverage
```bash
flutter test --coverage
```

### Watch Mode (auto-rerun on changes)
```bash
flutter test --watch
```

### Verbose Output
```bash
flutter test --verbose
```

---

## Unit Testing

### Testing BLoCs

**File**: `test/unit/blocs/auth_bloc_test.dart`

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:home_repair_app/blocs/auth/auth_bloc.dart';
import 'package:home_repair_app/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockAuthService mockAuthService;
    
    setUp(() {
      mockAuthService = MockAuthService();
      authBloc = AuthBloc(authService: mockAuthService);
    });
    
    tearDown(() {
      authBloc.close();
    });
    
    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });
    
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(mockAuthService.signInWithEmail(any, any))
            .thenAnswer((_) async => mockUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested(
        email: 'test@test.com',
        password: 'password123',
      )),
      expect: () match [
        AuthLoading(),
        isA<AuthAuthenticated>()
            .having((s) => s.user.email, 'email', 'test@test.com'),
      ],
      verify: (_) {
        verify(mockAuthService.signInWithEmail('test@test.com', 'password123'))
            .called(1);
      },
    );
    
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(mockAuthService.signInWithEmail(any, any))
            .thenThrow(Exception('Invalid credentials'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested(
        email: 'test@test.com',
        password: 'wrong',
      )),
      expect: () => [
        AuthLoading(),
        isA<AuthError>()
            .having((s) => s.message, 'message', contains('Invalid')),
      ],
    );
  });
}
```

### Testing Services

**File**: `test/unit/services/auth_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;
    
    setUp(() {
      mockAuth = MockFirebaseAuth();
      authService = AuthService(auth: mockAuth);
    });
    
    test('signInWithEmail returns UserModel on success', () async {
      // Arrange
      when(mockAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => MockUserCredential());
      
      // Act
      final user = await authService.signInWithEmail(
        'test@test.com',
        'password',
      );
      
      // Assert
      expect(user, isA<UserModel>());
      expect(user.email, 'test@test.com');
    });
  });
}
```

### Testing Models

**File**: `test/unit/models/order_model_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:home_repair_app/models/order_model.dart';

void main() {
  group('OrderModel', () {
    test('fromJson creates valid OrderModel', () {
      final json = {
        'id': 'order123',
        'customerId': 'user123',
        'serviceId': 'service001',
        'status': 'pending',
        // ... other fields
      };
      
      final order = OrderModel.fromJson(json);
      
      expect(order.id, 'order123');
      expect(order.status, OrderStatus.pending);
    });
    
    test('toJson serializes correctly', () {
      final order = OrderModel(/* ... */);
      final json = order.toJson();
      
      expect(json['id'], 'order123');
      expect(json['status'], 'pending');
    });
    
    test('copyWith creates new instance with updated fields', () {
      final order = OrderModel(status: OrderStatus.pending /* ... */);
      final updated = order.copyWith(status: OrderStatus.confirmed);
      
      expect(updated.status, OrderStatus.confirmed);
      expect(order.status, OrderStatus.pending); // Original unchanged
    });
  });
}
```

---

## Widget Testing

### Testing Screens

**File**: `test/widget/screens/login_screen_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('LoginScreen', () {
    late MockAuthBloc mockAuthBloc;
    
    setUp(() {
      mockAuthBloc = MockAuthBloc();
    });
    
    Widget createWidget() {
      return MaterialApp(
        home: BlocProvider<AuthBloc>(
          create: (_) => mockAuthBloc,
          child: LoginScreen(),
        ),
      );
    }
    
    testWidgets('displays email and password fields', (tester) async {
      await tester.pumpWidget(createWidget());
      
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });
    
    testWidgets('tapping login button dispatches event', (tester) async {
      await tester.pumpWidget(createWidget());
      
      // Enter credentials
      await tester.enterText(
        find.byKey(Key('email_field')),
        'test@test.com',
      );
      await tester.enterText(
        find.byKey(Key('password_field')),
        'password123',
      );
      
      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pump();
      
      // Verify event was dispatched
      verify(mockAuthBloc.add(AuthLoginRequested(
        email: 'test@test.com',
        password: 'password123',
      ))).called(1);
    });
    
    testWidgets('shows loading indicator when AuthLoading', (tester) async {
      whenListen(
        mockAuthBloc,
        Stream.fromIterable([AuthLoading()]),
        initialState: AuthInitial(),
      );
      
      await tester.pumpWidget(createWidget());
      await tester.pump(); // Rebuild after state change
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

### Testing Widgets

**File**: `test/widget/widgets/custom_button_test.dart`

```dart
testWidgets('CustomButton displays text and calls onPressed', (tester) async {
  bool pressed = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CustomButton(
          text: 'Click Me',
          onPressed: () => pressed = true,
        ),
      ),
    ),
  );
  
  expect(find.text('Click Me'), findsOneWidget);
  
  await tester.tap(find.byType(CustomButton));
  expect(pressed, isTrue);
});
```

---

## Integration Testing

### End-to-End User Flows

**File**: `integration_test/booking_flow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:home_repair_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Booking Flow', () {
    testWidgets('complete booking from service selection to confirmation',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 1. Login
      await tester.enterText(find.byKey(Key('email')), 'test@test.com');
      await tester.enterText(find.byKey(Key('password')), 'password');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      
      // 2. Select service
      await tester.tap(find.text('AC Repair'));
      await tester.pumpAndSettle();
      
      // 3. Fill booking form
      await tester.enterText(
        find.byKey(Key('description')),
        'AC not cooling',
      );
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      
      // 4. Confirm order
      await tester.tap(find.text('Confirm Booking'));
      await tester.pumpAndSettle();
      
      // 5. Verify success
      expect(find.text('Order placed successfully'), findsOneWidget);
    });
  });
}
```

**Run Integration Tests**:
```bash
flutter test integration_test/
```

---

## Mocking

### Creating Mocks with Mockito

**File**: `test/mocks/mock_services.dart`

```dart
import 'package:mockito/annotations.dart';
import 'package:home_repair_app/services/auth_service.dart';
import 'package:home_repair_app/services/firestore_service.dart';

@GenerateMocks([
  AuthService,
  FirestoreService,
  StorageService,
])
void main() {}
```

**Generate Mocks**:
```bash
flutter pub run build_runner build
```

### Using Mocks

```dart
import 'mocks/mock_services.mocks.dart';

final mockAuth = MockAuthService();

// Stub method
when(mockAuth.signIn(any, any))
    .thenAnswer((_) async => mockUser);

// Verify call
verify(mockAuth.signIn('email', 'password')).called(1);
```

---

## Coverage

### Generate Coverage Report

```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html  # macOS
start coverage/html/index.html # Windows
```

### Coverage Goals

- **Overall**: 80%+
- **BLoCs**: 90%+
- **Services**: 85%+
- **Models**: 95%+
- **Widgets**: 75%+

---

## Best Practices

1. **Test Behavior, Not Implementation**
2. **Keep Tests Independent**: Each test should run in isolation
3. **Use Descriptive Names**: `test('should emit error when credentials are invalid')`
4. **Arrange-Act-Assert Pattern**: Organize tests clearly
5. **Mock External Dependencies**: Firebase, APIs, etc.
6. **Test Edge Cases**: Nulls, empty lists, errors
7. **Avoid Testing Flutter Framework**: Don't test that `Text` displays text

---

_Last Updated: December 2025_
