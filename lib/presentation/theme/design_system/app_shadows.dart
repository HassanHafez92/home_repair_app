/// Design System - Shadows and Elevation
///
/// This file defines the shadow and elevation system for the application.
/// All shadows should be referenced from here to ensure consistency.
library;

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Elevation levels
class AppElevation {
  static const double none = 0.0;
  static const double xs = 1.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 12.0;
  static const double xxl = 16.0;
  static const double xxxl = 24.0;
}

/// Shadow definitions
class AppShadows {
  // No shadow
  static const List<BoxShadow> none = [];

  // Extra small shadow - elevation 1
  static final List<BoxShadow> xs = [
    BoxShadow(
      color: ShadowColors.shadowLight,
      offset: const Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  // Small shadow - elevation 2
  static final List<BoxShadow> sm = [
    BoxShadow(
      color: ShadowColors.shadowLight,
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  // Medium shadow - elevation 4
  static final List<BoxShadow> md = [
    BoxShadow(
      color: ShadowColors.shadow,
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: ShadowColors.shadow,
      offset: const Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Large shadow - elevation 8
  static final List<BoxShadow> lg = [
    BoxShadow(
      color: ShadowColors.shadow,
      offset: const Offset(0, 4),
      blurRadius: 8,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: ShadowColors.shadow,
      offset: const Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  // Extra large shadow - elevation 12
  static final List<BoxShadow> xl = [
    BoxShadow(
      color: ShadowColors.shadow,
      offset: const Offset(0, 6),
      blurRadius: 10,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: ShadowColors.shadow,
      offset: const Offset(0, 12),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  // Extra extra large shadow - elevation 16
  static final List<BoxShadow> xxl = [
    BoxShadow(
      color: ShadowColors.shadow,
      offset: const Offset(0, 8),
      blurRadius: 12,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: ShadowColors.shadow,
      offset: const Offset(0, 16),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  // Extra extra extra large shadow - elevation 24
  static final List<BoxShadow> xxxl = [
    BoxShadow(
      color: ShadowColors.shadowDark,
      offset: const Offset(0, 12),
      blurRadius: 16,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: ShadowColors.shadow,
      offset: const Offset(0, 24),
      blurRadius: 48,
      spreadRadius: 0,
    ),
  ];

  // Colored shadows for special cases
  static final List<BoxShadow> primary = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.3),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static final List<BoxShadow> secondary = [
    BoxShadow(
      color: AppColors.secondary.withValues(alpha: 0.3),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static final List<BoxShadow> error = [
    BoxShadow(
      color: SemanticColors.error.withValues(alpha: 0.3),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static final List<BoxShadow> success = [
    BoxShadow(
      color: SemanticColors.success.withValues(alpha: 0.3),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Inner shadow for pressed states
  static final List<BoxShadow> inner = [
    BoxShadow(
      color: ShadowColors.shadow.withValues(alpha: 0.15),
      offset: const Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
}

/// Shadow helpers for common components
class ComponentShadows {
  // Card shadows
  static List<BoxShadow> get card => AppShadows.sm;
  static List<BoxShadow> get cardElevated => AppShadows.md;
  static List<BoxShadow> get cardHovered => AppShadows.lg;

  // Button shadows
  static List<BoxShadow> get button => AppShadows.xs;
  static List<BoxShadow> get buttonPressed => AppShadows.inner;
  static List<BoxShadow> get buttonElevated => AppShadows.sm;

  // FAB shadows
  static List<BoxShadow> get fab => AppShadows.md;
  static List<BoxShadow> get fabExtended => AppShadows.lg;

  // Dialog shadows
  static List<BoxShadow> get dialog => AppShadows.xxl;
  static List<BoxShadow> get modal => AppShadows.xxxl;

  // Navigation shadows
  static List<BoxShadow> get bottomNav => AppShadows.md;
  static List<BoxShadow> get appBar => AppShadows.sm;

  // Input shadows
  static List<BoxShadow> get input => AppShadows.xs;
  static List<BoxShadow> get inputFocused => AppShadows.sm;
  static List<BoxShadow> get inputError => AppShadows.error;

  // Chip shadows
  static List<BoxShadow> get chip => AppShadows.xs;
  static List<BoxShadow> get chipSelected => AppShadows.sm;
}
