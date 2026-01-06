/// Responsive Layout Utilities
///
/// This file provides utilities for creating responsive layouts that adapt
/// to different screen sizes and orientations.
library;

import 'package:flutter/material.dart';

/// Screen size breakpoints
class ScreenBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Responsive layout builder
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= ScreenBreakpoints.desktop && desktop != null) {
      return desktop!;
    } else if (width >= ScreenBreakpoints.tablet && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Responsive value builder
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({required this.mobile, this.tablet, this.desktop});

  T getValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= ScreenBreakpoints.desktop && desktop != null) {
      return desktop!;
    } else if (width >= ScreenBreakpoints.tablet && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Responsive padding
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final ResponsiveValue<EdgeInsetsGeometry>? padding;

  const ResponsivePadding({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final effectivePadding =
        padding?.getValue(context) ??
        const ResponsiveValue(
          mobile: EdgeInsets.all(16),
          tablet: EdgeInsets.all(24),
          desktop: EdgeInsets.all(32),
        ).getValue(context);

    return Padding(padding: effectivePadding, child: child);
  }
}

/// Responsive grid
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final ResponsiveValue<int> crossAxisCount;
  final ResponsiveValue<double>? spacing;
  final ResponsiveValue<double>? runSpacing;
  final ResponsiveValue<double>? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    required this.crossAxisCount,
    this.spacing,
    this.runSpacing,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount.getValue(context),
      mainAxisSpacing: runSpacing?.getValue(context) ?? 8.0,
      crossAxisSpacing: spacing?.getValue(context) ?? 8.0,
      childAspectRatio: childAspectRatio?.getValue(context) ?? 1.0,
      children: children,
    );
  }
}

/// Responsive column
class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final ResponsiveValue<MainAxisAlignment>? mainAxisAlignment;
  final ResponsiveValue<CrossAxisAlignment>? crossAxisAlignment;
  final ResponsiveValue<double>? spacing;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing?.getValue(context) ?? 8.0;

    return Column(
      mainAxisAlignment:
          mainAxisAlignment?.getValue(context) ?? MainAxisAlignment.start,
      crossAxisAlignment:
          crossAxisAlignment?.getValue(context) ?? CrossAxisAlignment.start,
      children: _buildChildrenWithSpacing(effectiveSpacing),
    );
  }

  List<Widget> _buildChildrenWithSpacing(double spacing) {
    if (children.isEmpty) return children;

    return List<Widget>.generate(children.length * 2 - 1, (index) {
      if (index.isEven) return children[index ~/ 2];
      return SizedBox(height: spacing);
    });
  }
}

/// Responsive row
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final ResponsiveValue<MainAxisAlignment>? mainAxisAlignment;
  final ResponsiveValue<CrossAxisAlignment>? crossAxisAlignment;
  final ResponsiveValue<double>? spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSpacing = spacing?.getValue(context) ?? 8.0;

    return Row(
      mainAxisAlignment:
          mainAxisAlignment?.getValue(context) ?? MainAxisAlignment.start,
      crossAxisAlignment:
          crossAxisAlignment?.getValue(context) ?? CrossAxisAlignment.center,
      children: _buildChildrenWithSpacing(effectiveSpacing),
    );
  }

  List<Widget> _buildChildrenWithSpacing(double spacing) {
    if (children.isEmpty) return children;

    return List<Widget>.generate(children.length * 2 - 1, (index) {
      if (index.isEven) return children[index ~/ 2];
      return SizedBox(width: spacing);
    });
  }
}

/// Responsive container
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final ResponsiveValue<double>? width;
  final ResponsiveValue<double>? height;
  final ResponsiveValue<EdgeInsetsGeometry>? padding;
  final ResponsiveValue<EdgeInsetsGeometry>? margin;
  final ResponsiveValue<BoxDecoration>? decoration;
  final ResponsiveValue<BoxConstraints>? constraints;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.decoration,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width?.getValue(context);
    final effectiveHeight = height?.getValue(context);
    final effectivePadding = padding?.getValue(context);
    final effectiveMargin = margin?.getValue(context);
    final effectiveDecoration = decoration?.getValue(context);
    final effectiveConstraints = constraints?.getValue(context);

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      padding: effectivePadding,
      margin: effectiveMargin,
      decoration: effectiveDecoration,
      constraints: effectiveConstraints,
      child: child,
    );
  }
}

/// Helper to check screen size
class ScreenSize {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < ScreenBreakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ScreenBreakpoints.mobile &&
        width < ScreenBreakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= ScreenBreakpoints.desktop;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static Size size(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
