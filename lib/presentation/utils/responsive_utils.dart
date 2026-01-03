import 'package:flutter/material.dart';

/// Responsive breakpoint utilities for adaptive layouts
/// Based on Fixawy website analysis: 4/3/2/1 column grid system
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  // Breakpoint values
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1200;

  /// Check if current screen width is mobile (<480px)
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  /// Check if current screen width is tablet (480-1200px)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  /// Check if current screen width is desktop (>=1200px)
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;

  /// Get responsive value based on screen width
  /// Returns desktop value if available, falls back to tablet, then mobile
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// Get grid column count based on screen width
  /// Returns 4 for desktop, 3 for large tablet, 2 for tablet, 1 for mobile
  static int getGridColumns(double width) {
    if (width >= desktop) return 4;
    if (width >= tablet) return 3;
    if (width >= mobile) return 2;
    return 1;
  }

  /// Get card aspect ratio based on screen width
  /// Taller cards on desktop, wider on mobile
  static double getCardAspectRatio(double width) {
    if (width >= tablet) return 0.85; // Taller cards on desktop/tablet
    if (width >= mobile) return 0.9;
    return 1.2; // Wider cards on mobile
  }
}

/// Extension on BuildContext for easier access to responsive utilities
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveBreakpoints.isMobile(this);
  bool get isTablet => ResponsiveBreakpoints.isTablet(this);
  bool get isDesktop => ResponsiveBreakpoints.isDesktop(this);

  /// Get responsive padding based on screen size
  EdgeInsets get responsivePadding => ResponsiveBreakpoints.value(
    this,
    mobile: const EdgeInsets.all(12),
    tablet: const EdgeInsets.all(16),
    desktop: const EdgeInsets.all(24),
  );

  /// Get responsive horizontal padding
  double get responsiveHorizontalPadding => ResponsiveBreakpoints.value(
    this,
    mobile: 12.0,
    tablet: 16.0,
    desktop: 24.0,
  );
}
