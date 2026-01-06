/// Navigation Utilities
///
/// This file provides utilities for managing navigation throughout the
/// application, including route management, deep linking, and navigation history.
library;

import 'package:flutter/material.dart';

/// Navigation service
class NavigationService {
  // Singleton pattern
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final List<Route> _history = [];

  /// Get current context
  BuildContext? get context => navigatorKey.currentContext;

  /// Get current route
  Page<dynamic>? get currentRoute {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return null;
    return navigator.widget.pages.last;
  }

  /// Push new route
  Future<T?> push<T>(Route<T> route) async {
    _history.add(route);
    return navigatorKey.currentState?.push(route);
  }

  /// Push named route
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) async {
    return navigatorKey.currentState?.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Push route and remove until
  Future<T?> pushNamedAndRemoveUntil<T>(
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) async {
    return navigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
      newRouteName,
      predicate,
      arguments: arguments,
    );
  }

  /// Push route and replace
  Future<T?> pushReplacement<T, TO>(Route<T> newRoute, {TO? result}) async {
    if (_history.isNotEmpty) {
      _history.removeLast();
    }
    _history.add(newRoute);
    return navigatorKey.currentState?.pushReplacement<T, TO>(
      newRoute,
      result: result,
    );
  }

  /// Push named route and replace
  Future<T?> pushReplacementNamed<T, TO>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    if (_history.isNotEmpty) {
      _history.removeLast();
    }
    return navigatorKey.currentState?.pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// Pop current route
  void pop<T>([T? result]) {
    if (_history.isNotEmpty) {
      _history.removeLast();
    }
    navigatorKey.currentState?.pop<T>(result);
  }

  /// Pop until route
  void popUntil(RoutePredicate predicate) {
    while (_history.isNotEmpty && !predicate(_history.last)) {
      _history.removeLast();
    }
    navigatorKey.currentState?.popUntil(predicate);
  }

  /// Pop to first route
  void popToFirst() {
    _history.clear();
    navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  /// Clear navigation history
  void clearHistory() {
    _history.clear();
  }

  /// Get navigation history
  List<Route> get history => List.from(_history);

  /// Can pop
  bool canPop() {
    return navigatorKey.currentState?.canPop() ?? false;
  }
}

/// Route transition types
enum RouteTransition { fade, slide, scale, none }

/// Route utilities
class RouteUtils {
  /// Create material route with transition
  static Route<T> createRoute<T>({
    required WidgetBuilder builder,
    RouteTransition transition = RouteTransition.fade,
    Duration duration = const Duration(milliseconds: 300),
    bool fullscreenDialog = false,
  }) {
    switch (transition) {
      case RouteTransition.fade:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          fullscreenDialog: fullscreenDialog,
        );
      case RouteTransition.slide:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final curve = Curves.ease;

            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(
              tween.chain(CurveTween(curve: curve)),
            );

            return SlideTransition(position: offsetAnimation, child: child);
          },
          fullscreenDialog: fullscreenDialog,
        );
      case RouteTransition.scale:
        return PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            final curve = Curves.ease;

            final tween = Tween(begin: begin, end: end);
            final scaleAnimation = animation.drive(
              tween.chain(CurveTween(curve: curve)),
            );

            return ScaleTransition(scale: scaleAnimation, child: child);
          },
          fullscreenDialog: fullscreenDialog,
        );
      case RouteTransition.none:
        return MaterialPageRoute<T>(
          builder: builder,
          fullscreenDialog: fullscreenDialog,
        );
    }
  }

  /// Create dialog route
  static Route<T> createDialogRoute<T>({
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return DialogRoute<T>(
      context: NavigationService().context!,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
    );
  }

  /// Create bottom sheet route
  static Route<T> createBottomSheetRoute<T>({
    required WidgetBuilder builder,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    return ModalBottomSheetRoute<T>(
      builder: builder,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
    );
  }
}

/// Deep link utilities
class DeepLinkUtils {
  /// Parse deep link
  static Map<String, String>? parseDeepLink(String link) {
    try {
      final uri = Uri.parse(link);
      final Map<String, String> result = {};
      result['path'] = uri.path;
      uri.queryParameters.forEach((key, value) {
        result[key] = value;
      });
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Extract route from deep link
  static String? extractRoute(String link, String basePath) {
    final parsed = parseDeepLink(link);
    if (parsed == null) return null;

    final path = parsed['path'] as String;
    if (path.startsWith(basePath)) {
      return path.substring(basePath.length);
    }
    return null;
  }

  /// Extract parameters from deep link
  static Map<String, dynamic>? extractParameters(String link) {
    final parsed = parseDeepLink(link);
    return parsed?['query'] as Map<String, dynamic>?;
  }
}

/// Navigation guard utilities
class NavigationGuard {
  final Map<String, RouteGuard> _guards = {};

  /// Register guard for route
  void registerGuard(String route, RouteGuard guard) {
    _guards[route] = guard;
  }

  /// Unregister guard for route
  void unregisterGuard(String route) {
    _guards.remove(route);
  }

  /// Check if route can be navigated to
  Future<bool> canNavigate(String route, {Object? arguments}) async {
    final guard = _guards[route];
    if (guard == null) return true;

    return await guard.canNavigate(route, arguments: arguments);
  }

  /// Handle navigation with guards
  Future<T?> navigateWithGuard<T>(
    String route, {
    Object? arguments,
    required void Function() onBlocked,
  }) async {
    final canProceed = await canNavigate(route, arguments: arguments);
    if (canProceed) {
      return NavigationService().pushNamed<T>(route, arguments: arguments);
    } else {
      onBlocked();
      return null;
    }
  }
}

/// Route guard interface
abstract class RouteGuard {
  Future<bool> canNavigate(String route, {Object? arguments});
}

/// Authentication guard
class AuthGuard extends RouteGuard {
  final bool Function() isAuthenticated;

  AuthGuard({required this.isAuthenticated});

  @override
  Future<bool> canNavigate(String route, {Object? arguments}) async {
    // Allow navigation to auth routes
    if (_isAuthRoute(route)) {
      return true;
    }

    // Check if user is authenticated
    return isAuthenticated();
  }

  bool _isAuthRoute(String route) {
    return route == '/login' ||
        route == '/signup' ||
        route == '/forgot-password';
  }
}

/// Role-based guard
class RoleGuard extends RouteGuard {
  final String Function() getUserRole;
  final List<String> allowedRoles;

  RoleGuard({required this.getUserRole, required this.allowedRoles});

  @override
  Future<bool> canNavigate(String route, {Object? arguments}) async {
    final userRole = getUserRole();
    return allowedRoles.contains(userRole);
  }
}

/// Navigation history utilities
class NavigationHistory {
  static final NavigationHistory _instance = NavigationHistory._internal();
  factory NavigationHistory() => _instance;
  NavigationHistory._internal();

  final List<NavigationEntry> _entries = [];
  final int _maxEntries = 50;

  /// Add entry to history
  void addEntry(String route, {Object? arguments}) {
    _entries.add(
      NavigationEntry(
        route: route,
        arguments: arguments,
        timestamp: DateTime.now(),
      ),
    );

    // Remove old entries if exceeding max
    if (_entries.length > _maxEntries) {
      _entries.removeRange(0, _entries.length - _maxEntries);
    }
  }

  /// Get last entry
  NavigationEntry? get lastEntry {
    if (_entries.isEmpty) return null;
    return _entries.last;
  }

  /// Get previous entry
  NavigationEntry? get previousEntry {
    if (_entries.length < 2) return null;
    return _entries[_entries.length - 2];
  }

  /// Get entries for route
  List<NavigationEntry> getEntriesForRoute(String route) {
    return _entries.where((entry) => entry.route == route).toList();
  }

  /// Clear history
  void clear() {
    _entries.clear();
  }

  /// Get all entries
  List<NavigationEntry> get allEntries => List.from(_entries);
}

/// Navigation entry
class NavigationEntry {
  final String route;
  final Object? arguments;
  final DateTime timestamp;

  NavigationEntry({
    required this.route,
    this.arguments,
    required this.timestamp,
  });
}

/// Navigation analytics
class NavigationAnalytics {
  static final NavigationAnalytics _instance = NavigationAnalytics._internal();
  factory NavigationAnalytics() => _instance;
  NavigationAnalytics._internal();

  final Map<String, int> _routeVisits = {};
  final Map<String, DateTime> _lastVisit = {};
  final List<NavigationEvent> _events = [];

  /// Record route visit
  void recordVisit(String route) {
    _routeVisits[route] = (_routeVisits[route] ?? 0) + 1;
    _lastVisit[route] = DateTime.now();

    _events.add(
      NavigationEvent(
        type: NavigationEventType.visit,
        route: route,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Get visit count for route
  int getVisitCount(String route) {
    return _routeVisits[route] ?? 0;
  }

  /// Get last visit time for route
  DateTime? getLastVisit(String route) {
    return _lastVisit[route];
  }

  /// Get most visited routes
  List<RouteStats> getMostVisitedRoutes({int limit = 10}) {
    return _routeVisits.entries
        .map((e) => RouteStats(route: e.key, visits: e.value))
        .toList()
      ..sort((a, b) => b.visits.compareTo(a.visits))
      ..take(limit);
  }

  /// Clear analytics
  void clear() {
    _routeVisits.clear();
    _lastVisit.clear();
    _events.clear();
  }
}

/// Navigation event type
enum NavigationEventType { visit, back, forward, external }

/// Navigation event
class NavigationEvent {
  final NavigationEventType type;
  final String route;
  final DateTime timestamp;

  NavigationEvent({
    required this.type,
    required this.route,
    required this.timestamp,
  });
}

/// Route statistics
class RouteStats {
  final String route;
  final int visits;

  RouteStats({required this.route, required this.visits});
}
