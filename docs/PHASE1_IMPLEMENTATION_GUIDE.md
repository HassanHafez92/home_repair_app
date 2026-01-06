
# Phase 1 Implementation Guide

This guide provides step-by-step instructions for implementing Phase 1 enhancements in the Home Repair App.

## Table of Contents

1. [Service Integration](#service-integration)
2. [Performance Monitoring](#performance-monitoring)
3. [Error Handling](#error-handling)
4. [Accessibility](#accessibility)
5. [Responsive Design](#responsive-design)
6. [Design System](#design-system)
7. [State Management](#state-management)
8. [Validation](#validation)
9. [Navigation](#navigation)
10. [Storage](#storage)

## Service Integration

### Step 1: Initialize Services in main.dart

Add service initialization to your `main_common.dart`:

```dart
import 'package:home_repair_app/core/services/service_integration.dart';

Future<void> mainCommon(AppConfig config) async {
  // ... existing initialization code ...

  // Initialize Phase 1 services
  await ServiceIntegration().initialize(
    onProgress: (serviceName, status) {
      debugPrint('$serviceName: $status');
    },
  );

  // ... rest of your initialization code ...
}
```

### Step 2: Wrap App with Service Initialization

```dart
import 'package:home_repair_app/presentation/widgets/wrappers.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ServiceInitializationWrapper(
      requiredServices: [
        'LoggingService',
        'ErrorHandlingService',
        'PerformanceMonitoringService',
        // Add other required services
      ],
      builder: (context, initialized) {
        if (!initialized) {
          return const Center(child: CircularProgressIndicator());
        }
        return YourExistingAppWidget();
      },
    );
  }
}
```

## Performance Monitoring

### Step 1: Wrap Screens with Performance Monitor

```dart
import 'package:home_repair_app/presentation/widgets/wrappers.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PerformanceMonitorWrapper(
      screenName: 'HomeScreen',
      onMetricsCollected: (metrics) {
        // Handle performance metrics
        if (!metrics.isGoodPerformance) {
          debugPrint('Performance issue: ${metrics.toString()}');
        }
      },
      child: Scaffold(
        // Your screen content
      ),
    );
  }
}
```

### Step 2: Track Specific Operations

```dart
import 'package:home_repair_app/services/performance_monitoring_service.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    PerformanceMonitoringService().startScreenLoad('MyWidget');
  }

  @override
  void dispose() {
    PerformanceMonitoringService().endScreenLoad('MyWidget');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Your widget content
  }
}
```

## Error Handling

### Step 1: Wrap Widgets with Error Boundary

```dart
import 'package:home_repair_app/presentation/widgets/wrappers.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ErrorBoundaryWrapper(
      fallbackTitle: 'Error Loading Screen',
      fallbackMessage: 'Please try again later.',
      onRetry: () {
        // Retry logic
      },
      child: Scaffold(
        // Your screen content
      ),
    );
  }
}
```

### Step 2: Handle Errors in BLoCs

```dart
import 'package:home_repair_app/services/error_handling_service.dart';

class MyBloc extends Bloc<MyEvent, MyState> {
  final ErrorHandlingService _errorHandler = ErrorHandlingService();

  MyBloc() : super(MyInitial()) {
    on<LoadData>(_onLoadData);
  }

  Future<void> _onLoadData(LoadData event, Emitter<MyState> emit) async {
    emit(MyLoading());
    try {
      final data = await repository.getData();
      emit(MyLoaded(data));
    } catch (e, stackTrace) {
      await _errorHandler.handleError(
        e,
        stackTrace: stackTrace,
        recoveryStrategy: ErrorRecoveryStrategies.retry(() {
          add(LoadData());
        }),
      );
      emit(MyError(e.toString()));
    }
  }
}
```

## Accessibility

### Step 1: Add Accessibility Labels

```dart
import 'package:home_repair_app/presentation/widgets/wrappers.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AccessibleButton(
          label: 'Back',
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          AccessibleButton(
            label: 'Submit',
            hint: 'Submit the form',
            onPressed: () {
              // Handle press
            },
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 2: Use Accessibility Extensions

```dart
import 'package:home_repair_app/presentation/utils/utils.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: Text('Submit'),
    ).withAccessibility(
      label: 'Submit',
      hint: 'Submit the form',
    );
  }
}
```

## Responsive Design

### Step 1: Use Responsive Layout

```dart
import 'package:home_repair_app/presentation/utils/utils.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Mobile content
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Tablet content
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Desktop content
      ],
    );
  }
}
```

### Step 2: Use Responsive Values

```dart
import 'package:home_repair_app/presentation/utils/utils.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveValue(
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    ).getValue(context);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: Text('Content'),
    );
  }
}
```

## Design System

### Step 1: Use Design System Colors

```dart
import 'package:home_repair_app/presentation/theme/design_system/design_system.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      child: Text(
        'Hello',
        style: AppTextStyles.headlineLarge,
      ),
    );
  }
}
```

### Step 2: Use Design System Spacing

```dart
import 'package:home_repair_app/presentation/theme/design_system/design_system.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppEdgeInsets.all,
      child: Column(
        children: [
          Text('Item 1'),
          Gap.lg(),
          Text('Item 2'),
        ],
      ),
    );
  }
}
```

## State Management

### Step 1: Use State Persistence

```dart
import 'package:home_repair_app/presentation/utils/utils.dart';

class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyInitial()) {
    on<LoadData>(_onLoadData);
  }

  Future<void> _onLoadData(LoadData event, Emitter<MyState> emit) async {
    // Load from persistence
    final cached = await StatePersistence.loadState<MyData>('my_data');
    if (cached != null) {
      emit(MyLoaded(cached));
    }

    // Fetch fresh data
    final data = await repository.getData();

    // Save to persistence
    await StatePersistence.saveState('my_data', data);

    emit(MyLoaded(data));
  }
}
```

### Step 2: Use State Caching

```dart
import 'package:home_repair_app/presentation/utils/utils.dart';

class MyBloc extends Bloc<MyEvent, MyState> {
  final StateCache<MyData> _cache = StateCache(
    ttl: Duration(minutes: 5),
  );

  MyBloc() : super(MyInitial()) {
    on<LoadData>(_onLoadData);
  }

  Future<void> _onLoadData(LoadData event, Emitter<MyState> emit) async {
    // Check cache
    final cached = _cache.get('my_data');
    if (cached != null) {
      emit(MyLoaded(cached));
      return;
    }

    // Fetch fresh data
    final data = await repository.getData();

    // Update cache
    _cache.set('my_data', data);

    emit(MyLoaded(data));
  }
}
```

## Validation

### Step 1: Use Built-in Validators

```dart
import 'package:home_repair_app/presentation/utils/utils.dart';

class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              final result = EmailValidator.validate(value);
              return result.isValid ? null : result.errorMessage;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              final result = PasswordValidator.validate(value);
              return result.isValid ? null : result.errorMessage;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Submit form
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

### Step 2: Use Form Validator

```dart
import 'package:home_repair_app/presentation/utils/utils.dart';

class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formValidator = FormValidator();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formValidator.addRule('email', ValidationRule(
      'Please enter a valid email',
      (value) => EmailValidator.validate(value).isValid,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (value) {
              final result = _formValidator.validateField('email', value ?? '');
              return result.isValid ? null : result.errorMessage;
            },
          ),
          ElevatedButton(
            onPressed: () {
              final results = _formValidator.validateAll({
                'email': _emailController.text,
              });

              if (results.values.every((r) => r.isValid)) {
                // Submit form
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
```

## Navigation

### Step 1: Use Navigation Service

```dart
import 'package:home_repair_app/presentation/utils/utils.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        NavigationService().pushNamed('/details');
      },
      child: Text('Go to Details'),
    );
  }
}
```

### Step 2: Use Navigation Guards

```dart
import 'package:home_repair_app/presentation/utils/utils.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        NavigationGuard().navigateWithGuard(
          '/protected',
          onBlocked: () {
            // Show error or redirect
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Access denied')),
            );
          },
        );
      },
      child: Text('Go to Protected'),
    );
  }
}
```

## Storage

### Step 1: Use Storage Service

```dart
import 'package:home_repair_app/services/services.dart';

class MyBloc extends Bloc<MyEvent, MyState> {
  final StorageService _storage = StorageService();

  MyBloc() : super(MyInitial()) {
    on<SaveData>(_onSaveData);
    on<LoadData>(_onLoadData);
  }

  Future<void> _onSaveData(SaveData event, Emitter<MyState> emit) async {
    await _storage.saveString('my_key', event.value);
    emit(MySaved());
  }

  Future<void> _onLoadData(LoadData event, Emitter<MyState> emit) async {
    final value = _storage.getString('my_key');
    emit(MyLoaded(value));
  }
}
```

### Step 2: Use Secure Storage

```dart
import 'package:home_repair_app/services/services.dart';

class MyBloc extends Bloc<MyEvent, MyState> {
  final StorageService _storage = StorageService();

  MyBloc() : super(MyInitial()) {
    on<SaveToken>(_onSaveToken);
    on<LoadToken>(_onLoadToken);
  }

  Future<void> _onSaveToken(SaveToken event, Emitter<MyState> emit) async {
    await _storage.saveSecureString('auth_token', event.token);
    emit(TokenSaved());
  }

  Future<void> _onLoadToken(LoadToken event, Emitter<MyState> emit) async {
    final token = await _storage.getSecureString('auth_token');
    emit(TokenLoaded(token));
  }
}
```

## Best Practices

### Performance
1. Always wrap screens with `PerformanceMonitorWrapper`
2. Track critical user flows
3. Monitor performance metrics regularly
4. Optimize based on metrics

### Error Handling
1. Wrap all widgets with `ErrorBoundaryWrapper`
2. Handle errors in BLoCs
3. Provide user-friendly error messages
4. Implement recovery strategies

### Accessibility
1. Add semantic labels to all interactive elements
2. Ensure proper contrast ratios
3. Test with screen readers
4. Support keyboard navigation

### Responsive Design
1. Test on multiple screen sizes
2. Use responsive layouts for all screens
3. Optimize for different orientations
4. Consider touch target sizes

## Troubleshooting

### Services Not Initializing
- Check service initialization order
- Verify dependencies are installed
- Review initialization logs
- Check for circular dependencies

### Performance Issues
- Use performance monitoring to identify bottlenecks
- Check for unnecessary rebuilds
- Optimize image loading
- Implement lazy loading

### Accessibility Issues
- Test with screen readers
- Verify semantic labels
- Check contrast ratios
- Test keyboard navigation

## Next Steps

1. Implement all screens with new wrappers
2. Add comprehensive test coverage
3. Monitor performance metrics
4. Gather user feedback
5. Iterate and improve
