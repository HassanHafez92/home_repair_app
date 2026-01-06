/// Test Helpers
///
/// This file provides common utilities and helpers for writing tests
/// across the application.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Mock classes
@GenerateMocks([
  // Add your mock classes here
  // Example: NavigatorObserver, BuildContext, etc.
])
void main() {}

/// Test wrapper for widget tests
class TestApp extends StatelessWidget {
  final Widget child;
  final ThemeData? theme;
  final Locale? locale;
  final List<BlocProvider>? blocProviders;

  const TestApp({
    super.key,
    required this.child,
    this.theme,
    this.locale,
    this.blocProviders,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      locale: locale ?? const Locale('en'),
      home: MultiBlocProvider(providers: blocProviders ?? [], child: child),
    );
  }
}

/// Helper to pump and settle widget with custom timeout
Future<void> pumpAndSettleWithTimeout(
  WidgetTester tester,
  Widget widget, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
}

/// Helper to find widgets by key
Finder findWidgetByKey(String key) {
  return find.byKey(Key(key));
}

/// Helper to find widgets by type
Finder findWidgetByType<T extends Widget>() {
  return find.byType(T);
}

/// Helper to find widgets by text
Finder findWidgetByText(String text) {
  return find.text(text);
}

/// Helper to find widgets by icon
Finder findWidgetByIcon(IconData icon) {
  return find.byIcon(icon);
}

/// Helper to verify widget exists
void expectWidgetExists(Finder finder) {
  expect(finder, findsOneWidget);
}

/// Helper to verify widget doesn't exist
void expectWidgetNotExists(Finder finder) {
  expect(finder, findsNothing);
}

/// Helper to verify widget is visible
void expectWidgetVisible(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);
  expect(tester.widget<Opacity>(finder).opacity, equals(1.0));
}

/// Helper to verify widget is hidden
void expectWidgetHidden(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);
  expect(tester.widget<Opacity>(finder).opacity, lessThan(1.0));
}

/// Helper to tap on widget
Future<void> tapWidget(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Helper to enter text in text field
Future<void> enterText(WidgetTester tester, Finder finder, String text) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

/// Helper to scroll until widget is found
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder, {
  Finder? scrollable,
  double delta = 100.0,
  int maxScrolls = 50,
}) async {
  scrollable ??= find.byType(Scrollable);
  int scrollCount = 0;
  while (scrollCount < maxScrolls) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.drag(scrollable, Offset(0.0, -delta));
    await tester.pumpAndSettle();
    scrollCount++;
  }
  throw Exception('Widget not found after $maxScrolls scrolls');
}

/// Helper to wait for widget to appear
Future<void> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  await tester.pumpAndSettle();
  final end = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(end)) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 100));
    await tester.pump();
  }

  throw Exception('Widget did not appear within timeout');
}

/// Helper to create mock navigator observer
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

/// Helper to verify route was pushed
void verifyRoutePushed(MockNavigatorObserver mockObserver, Route route) {
  verify(mockObserver.didPush(route, any));
}

/// Helper to verify route was popped
void verifyRoutePopped(MockNavigatorObserver mockObserver, Route route) {
  verify(mockObserver.didPop(route, any));
}

/// Helper to create test bloc provider
BlocProvider<B> createTestBlocProvider<B extends BlocBase<Object?>>(B bloc) {
  return BlocProvider<B>.value(value: bloc);
}

/// Helper to create test cubit provider
BlocProvider<C> createTestCubitProvider<C extends Cubit<Object?>>(C cubit) {
  return BlocProvider<C>.value(value: cubit);
}

/// Helper to verify bloc state
void expectBlocState<B extends BlocBase<S>, S>(B bloc, S expectedState) {
  expect(bloc.state, equals(expectedState));
}

/// Helper to wait for bloc state
Future<void> waitForBlocState<B extends BlocBase<S>, S>(
  B bloc,
  S expectedState, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final end = DateTime.now().add(timeout);
  StreamSubscription? subscription;

  try {
    subscription = bloc.stream.listen((state) {
      if (state == expectedState) {
        return;
      }
      if (DateTime.now().isAfter(end)) {
        throw TimeoutException(
          'Bloc did not reach expected state within timeout',
          timeout,
        );
      }
    });
    
    // Wait for the expected state or timeout
    await bloc.stream.firstWhere(
      (state) => state == expectedState,
      orElse: () => bloc.state,
    );
  } finally {
    await subscription?.cancel();
  }
}

/// Helper to create test theme
ThemeData createTestTheme({Brightness brightness = Brightness.light}) {
  return ThemeData(
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: brightness,
    ),
  );
}

/// Helper to create test locale
Locale createTestLocale({String languageCode = 'en', String? countryCode}) {
  return Locale(languageCode, countryCode);
}

/// Helper to create test widget with given parameters
Widget createTestWidget({
  required Widget child,
  ThemeData? theme,
  Locale? locale,
  List<BlocProvider>? blocProviders,
}) {
  return TestApp(
    theme: theme,
    locale: locale,
    blocProviders: blocProviders,
    child: child,
  );
}
