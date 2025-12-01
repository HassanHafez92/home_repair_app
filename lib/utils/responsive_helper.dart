// File: lib/utils/responsive_helper.dart
// Purpose: Responsive design utilities for various screen sizes

import 'package:flutter/material.dart';

/// Breakpoint constants for responsive design
class _ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double desktopMaxWidth = 1200;
}

/// Padding constants for different screen sizes
class _ResponsivePadding {
  static const double small = 12;
  static const double medium = 16;
  static const double large = 20;
  static const double extraLarge = 24;
}

/// Grid column counts for different screen sizes
class _ResponsiveGrid {
  static const int mobileColumns = 2;
  static const int tabletColumns = 3;
  static const int desktopColumns = 4;
}

/// Helper class for responsive design
class ResponsiveHelper {
  /// Private constructor
  ResponsiveHelper._();

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < _ResponsiveBreakpoints.tablet;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _ResponsiveBreakpoints.tablet &&
        width < _ResponsiveBreakpoints.desktop;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= _ResponsiveBreakpoints.desktop;
  }

  /// Get device width
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get device height
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Get screen orientation
  static Orientation getOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Check if in landscape
  static bool isLandscape(BuildContext context) {
    return getOrientation(context) == Orientation.landscape;
  }

  /// Check if in portrait
  static bool isPortrait(BuildContext context) {
    return getOrientation(context) == Orientation.portrait;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive padding based on screen size
  static double getResponsivePadding(BuildContext context) {
    final width = getWidth(context);
    if (width < _ResponsiveBreakpoints.mobile) {
      return _ResponsivePadding.small;
    } else if (width < _ResponsiveBreakpoints.tablet) {
      return _ResponsivePadding.medium;
    } else if (width < _ResponsiveBreakpoints.desktop) {
      return _ResponsivePadding.large;
    } else {
      return _ResponsivePadding.extraLarge;
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    double mobileSize = 14,
    double tabletSize = 16,
    double desktopSize = 18,
  }) {
    if (isMobile(context)) {
      return mobileSize;
    } else if (isTablet(context)) {
      return tabletSize;
    } else {
      return desktopSize;
    }
  }

  /// Get responsive grid columns
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return _ResponsiveGrid.mobileColumns;
    } else if (isTablet(context)) {
      return _ResponsiveGrid.tabletColumns;
    } else {
      return _ResponsiveGrid.desktopColumns;
    }
  }

  /// Get responsive width (percentage of screen)
  static double getResponsiveWidth(
    BuildContext context, {
    required double percentage,
  }) {
    return getWidth(context) * (percentage / 100);
  }

  /// Get responsive height (percentage of screen)
  static double getResponsiveHeight(
    BuildContext context, {
    required double percentage,
  }) {
    return getHeight(context) * (percentage / 100);
  }

  /// Build responsive layout
  static Widget buildResponsiveLayout(
    BuildContext context, {
    required Widget mobile,
    required Widget tablet,
    required Widget desktop,
  }) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  /// Build adaptive layout (for portrait/landscape)
  static Widget buildAdaptiveLayout(
    BuildContext context, {
    required Widget portrait,
    required Widget landscape,
  }) {
    if (isPortrait(context)) {
      return portrait;
    } else {
      return landscape;
    }
  }

  /// Get device pixel ratio
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Get viewport insets
  static EdgeInsets getViewportInsets(BuildContext context) {
    return MediaQuery.of(context).viewInsets;
  }

  /// Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }

  /// Get keyboard height
  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }
}

/// Responsive value helper
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  ResponsiveValue({required this.mobile, this.tablet, this.desktop});

  /// Get value based on current screen size
  T getValue(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (ResponsiveHelper.isTablet(context) && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Widget that rebuilds on orientation changes
class OrientationBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Orientation orientation) builder;

  const OrientationBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(context, MediaQuery.of(context).orientation);
  }
}

/// Build responsive container with adaptive padding
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  maxWidth ??
                  (ResponsiveHelper.isDesktop(context)
                      ? _ResponsiveBreakpoints.desktopMaxWidth
                      : double.infinity),
            ),
            child: Padding(
              padding:
                  padding ??
                  EdgeInsets.all(
                    ResponsiveHelper.getResponsivePadding(context),
                  ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
