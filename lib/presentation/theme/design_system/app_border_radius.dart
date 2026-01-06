/// Design System - Border Radius
///
/// This file defines the border radius scale for the application.
/// All border radius values should be referenced from here to ensure consistency.
library;

import 'package:flutter/material.dart';

/// Border radius scale
class AppBorderRadius {
  // Radius values
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double circle = 9999.0; // For circular shapes

  // Common border radius values
  static const double card = md;
  static const double button = sm;
  static const double input = sm;
  static const double dialog = lg;
  static const double modal = lg;
  static const double chip = xl;
  static const double badge = circle;
  static const double avatar = circle;
  static const double fab = circle;
}

/// BorderRadius helpers
class AppBorderRadiuses {
  // All corners
  static const BorderRadius all = BorderRadius.all(
    Radius.circular(AppBorderRadius.md),
  );
  static const BorderRadius allSmall = BorderRadius.all(
    Radius.circular(AppBorderRadius.sm),
  );
  static const BorderRadius allLarge = BorderRadius.all(
    Radius.circular(AppBorderRadius.lg),
  );
  static const BorderRadius circular = BorderRadius.all(
    Radius.circular(AppBorderRadius.circle),
  );

  // Top corners
  static const BorderRadius top = BorderRadius.vertical(
    top: Radius.circular(AppBorderRadius.md),
  );
  static const BorderRadius topSmall = BorderRadius.vertical(
    top: Radius.circular(AppBorderRadius.sm),
  );
  static const BorderRadius topLarge = BorderRadius.vertical(
    top: Radius.circular(AppBorderRadius.lg),
  );

  // Bottom corners
  static const BorderRadius bottom = BorderRadius.vertical(
    bottom: Radius.circular(AppBorderRadius.md),
  );
  static const BorderRadius bottomSmall = BorderRadius.vertical(
    bottom: Radius.circular(AppBorderRadius.sm),
  );
  static const BorderRadius bottomLarge = BorderRadius.vertical(
    bottom: Radius.circular(AppBorderRadius.lg),
  );

  // Specific corners
  static const BorderRadius topLeft = BorderRadius.only(
    topLeft: Radius.circular(AppBorderRadius.md),
  );
  static const BorderRadius topRight = BorderRadius.only(
    topRight: Radius.circular(AppBorderRadius.md),
  );
  static const BorderRadius bottomLeft = BorderRadius.only(
    bottomLeft: Radius.circular(AppBorderRadius.md),
  );
  static const BorderRadius bottomRight = BorderRadius.only(
    bottomRight: Radius.circular(AppBorderRadius.md),
  );

  // Component-specific
  static const BorderRadius card = BorderRadius.all(
    Radius.circular(AppBorderRadius.card),
  );
  static const BorderRadius button = BorderRadius.all(
    Radius.circular(AppBorderRadius.button),
  );
  static const BorderRadius input = BorderRadius.all(
    Radius.circular(AppBorderRadius.input),
  );
  static const BorderRadius dialog = BorderRadius.all(
    Radius.circular(AppBorderRadius.dialog),
  );
  static const BorderRadius modal = BorderRadius.all(
    Radius.circular(AppBorderRadius.modal),
  );
  static const BorderRadius chip = BorderRadius.all(
    Radius.circular(AppBorderRadius.chip),
  );
  static const BorderRadius badge = BorderRadius.all(
    Radius.circular(AppBorderRadius.badge),
  );
  static const BorderRadius avatar = BorderRadius.all(
    Radius.circular(AppBorderRadius.avatar),
  );
  static const BorderRadius fab = BorderRadius.all(
    Radius.circular(AppBorderRadius.fab),
  );
}

/// Shape border helpers
class AppShapeBorders {
  // Rounded rectangle
  static RoundedRectangleBorder roundedRectangle({
    double borderRadius = AppBorderRadius.md,
  }) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  static RoundedRectangleBorder roundedRectangleSmall() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
    );
  }

  static RoundedRectangleBorder roundedRectangleLarge() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
    );
  }

  // Circle
  static const CircleBorder circle = CircleBorder();

  // Stadium (pill shape)
  static const StadiumBorder stadium = StadiumBorder();

  // Beveled rectangle
  static BeveledRectangleBorder beveledRectangle({
    double borderRadius = AppBorderRadius.md,
  }) {
    return BeveledRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  // Continuous rectangle (smooth corners)
  static ContinuousRectangleBorder continuousRectangle({
    double borderRadius = AppBorderRadius.md,
  }) {
    return ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}
