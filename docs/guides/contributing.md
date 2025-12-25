# Contributing Guide

Thank you for contributing to the Home Repair App! This guide will help you understand our development workflow and coding standards.

## Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)

---

## Code of Conduct

- Be respectful and professional
- Provide constructive feedback
- Help others learn and grow
- Focus on code quality over speed

---

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/home_repair_app.git`
3. Set up your environment: See [developer_onboarding.md](developer_onboarding.md)
4. Create a branch: `git checkout -b feature/your-feature`

---

## Development Workflow

### Branch Naming Convention

- **Features**: `feature/short-description`
- **Bugs**: `bugfix/issue-number-description`
- **Hotfixes**: `hotfix/critical-issue`
- **Chores**: `chore/task-description`

Examples:
- `feature/add-payment-gateway`
- `bugfix/123-fix-login-crash`
- `hotfix/security-patch`

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples**:
```
feat(auth): add Google Sign-In support

Implemented Google Sign-In authentication flow using firebase_auth.
Added UI button and BLoC logic.

Closes #45
```

```
fix(booking): prevent duplicate order submissions

Added debouncing to booking confirmation button to prevent
multiple taps from creating duplicate orders.

Fixes #78
```

---

## Coding Standards

### Dart Style Guide

Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide.

**Key Rules**:
1. **Naming**:
   - Classes: `PascalCase`
   - Variables/functions: `camelCase`
   - Constants: `lowerCamelCase`
   - Files: `snake_case.dart`

2. **Formatting**:
   - Run `flutter format .` before committing
   - Max line length: 80 characters (auto-formatted)
   - Use trailing commas for multi-line lists

3. **Imports**:
   ```dart
   // Dart imports
   import 'dart:async';
   
   // Flutter imports
   import 'package:flutter/material.dart';
   
   // Package imports
   import 'package:firebase_core/firebase_core.dart';
   import 'package:flutter_bloc/flutter_bloc.dart';
   
   // Relative imports
   import '../models/user_model.dart';
   import '../services/auth_service.dart';
   ```

### BLoC Pattern Standards

**1. File Structure** (for each feature):
```
lib/presentation/blocs/feature_name/
├── feature_bloc.dart
├── feature_event.dart
└── feature_state.dart
```

**2. Event Naming**:
```dart
// Use past tense + "Requested"
class AuthLoginRequested extends AuthEvent {}
class OrderCancelRequested extends OrderEvent {}
```

**3. State Naming**:
```dart
// Use present tense or past participle
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {}
class OrderError extends OrderState {}
```

**4. BLoC Implementation**:
```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  final MyService service;
  
  MyBloc({required this.service}) : super(MyInitial()) {
    on<MyEventTriggered>(_onEventTriggered);
  }
  
  Future<void> _onEventTriggered(
    MyEventTriggered event,
    Emitter<MyState> emit,
  ) async {
    emit(MyLoading());
    try {
      final result = await service.doSomething();
      emit(MySuccess(data: result));
    } catch (e) {
      emit(MyError(message: e.toString()));
    }
  }
}
```

### Widget Standards

**1. Stateless vs Stateful**:
- **Prefer StatelessWidget** whenever possible
- Use **StatefulWidget** only for:
  - Form controllers
  - Animation controllers
  - Local UI state (not business logic)

**2. Widget Composition**:
- Break large widgets into smaller, reusable components
- Extract repeated UI patterns into custom widgets
- Keep `build()` methods under 50 lines

**Example**:
```dart
// ❌ Bad: Monolithic widget
class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 200 lines of nested widgets...
    );
  }
}

// ✅ Good: Composed widgets
class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: OrderList(),
      floatingActionButton: NewOrderButton(),
    );
  }
}
```

### Service Layer Standards

**1. Interface First** (when possible):
```dart
abstract class AuthRepository {
  Future<UserModel> signIn(String email, String password);
  Future<void> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  
  @override
  Future<UserModel> signIn(String email, String password) async {
    // Implementation
  }
}
```

**2. Error Handling**:
```dart
// Throw custom exceptions
throw AuthException('Invalid credentials');

// Not generic exceptions
throw Exception('Something went wrong'); // ❌
```

### Model Standards

**1. Use Equatable**:
```dart
class UserModel extends Equatable {
  final String id;
  final String name;
  
  const UserModel({required this.id, required this.name});
  
  @override
  List<Object?> get props => [id, name];
}
```

**2. JSON Serialization**:
```dart
@JsonSerializable(explicitToJson: true)
class OrderModel {
  final String id;
  final String customerId;
  
  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
```

### Documentation Standards

**1. Public API Documentation**:
```dart
/// Signs in a user with email and password.
///
/// Throws [AuthException] if credentials are invalid.
/// Returns the authenticated [UserModel] on success.
Future<UserModel> signIn(String email, String password) async {
  // Implementation
}
```

**2. Complex Logic Comments**:
```dart
// Calculate total price including VAT and visit fee
// Formula: (servicePrice + visitFee) * (1 + vatRate)
final totalPrice = (order.servicePrice + order.visitFee) * 1.15;
```

---

## Pull Request Process

### Before Submitting

**Checklist**:
- [ ] Code follows style guidelines
- [ ] All tests pass: `flutter test`
- [ ] No linter errors: `flutter analyze`
- [ ] Code is formatted: `flutter format .`
- [ ] Added tests for new features
- [ ] Updated documentation if needed
- [ ] Tested on both Android and iOS (if applicable)

### PR Template

```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [x] Breaking change
- [ ] Documentation update

## Changes Made
- Added payment gateway integration
- Updated order model with payment fields
- Added payment confirmation screen

## Testing
- Tested on Android emulator
- Tested on iOS simulator
- Added unit tests for PaymentBloc

## Screenshots (if applicable)
[Add screenshots here]

## Related Issues
Closes #123
```

### Review Process

1. **Submit PR**: Push your branch and create a pull request
2. **Automated Checks**: CI/CD runs tests and linters
3. **Code Review**: Team members review your code
4. **Address Feedback**: Make requested changes
5. **Approval**: PR is approved by reviewers
6. **Merge**: Maintainer merges PR into main branch

---

## Testing Guidelines

### Test Structure

```
test/
├── unit/            # Unit tests for BLoCs, services, models
├── widget/          # Widget tests for UI components
├── integration/     # Integration tests for user flows
└── mocks/           # Mock objects for testing
```

### Unit Testing

**Testing BLoCs**:
```dart
group('AuthBloc', () {
  late AuthBloc authBloc;
  late MockAuthService mockAuthService;
  
  setUp(() {
    mockAuthService = MockAuthService();
    authBloc = AuthBloc(authService: mockAuthService);
  });
  
  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when login succeeds',
    build: () => authBloc,
    act: (bloc) => bloc.add(AuthLoginRequested(
      email: 'test@test.com',
      password: 'password',
    )),
    expect: () => [
      AuthLoading(),
      AuthAuthenticated(user: mockUser),
    ],
  );
});
```

**Testing Services**:
```dart
test('signIn returns UserModel on success', () async {
  final authService = AuthService();
  final user = await authService.signIn('test@test.com', 'password');
  
  expect(user, isA<UserModel>());
  expect(user.email, 'test@test.com');
});
```

### Widget Testing

```dart
testWidgets('LoginScreen displays email and password fields', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: LoginScreen()),
  );
  
  expect(find.byKey(Key('email_field')), findsOneWidget);
  expect(find.byKey(Key('password_field')), findsOneWidget);
  expect(find.text('Login'), findsOneWidget);
});
```

### Test Coverage

**Target**: 80% code coverage

**Check Coverage**:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Additional Resources

- [Flutter Best Practices](https://docs.flutter.dev/testing/best-practices)
- [BLoC Library Documentation](https://bloclibrary.dev/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

---

**Thank you for contributing! 🎉**

_Last Updated: December 2025_
