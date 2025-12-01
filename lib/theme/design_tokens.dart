// File: lib/theme/design_tokens.dart
// Purpose: Design system tokens for consistent styling across the app

import 'package:flutter/material.dart';

/// Design tokens for the Home Repair App
/// Use these tokens instead of hard-coded values for consistency
class DesignTokens {
  // Prevent instantiation
  DesignTokens._();

  // ========== Color Palette ==========

  /// Primary brand colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0xFF64B5F6);

  /// Accent colors
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentRed = Color(0xFFF44336);

  /// Neutral colors
  static const Color neutral900 = Color(0xFF212121);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral50 = Color(0xFFFAFAFA);

  /// Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  /// Background colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFAFAFA);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // ========== Typography ==========

  /// Font family
  static const String fontFamily = 'Roboto';

  /// Font sizes
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeBase = 14.0;
  static const double fontSizeMD = 16.0;
  static const double fontSizeLG = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSize2XL = 24.0;
  static const double fontSize3XL = 30.0;
  static const double fontSize4XL = 36.0;

  /// Font weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  /// Line heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // ========== Spacing ==========

  static const double spaceXXS = 2.0;
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 12.0;
  static const double spaceBase = 16.0;
  static const double spaceLG = 20.0;
  static const double spaceXL = 24.0;
  static const double space2XL = 32.0;
  static const double space3XL = 40.0;
  static const double space4XL = 48.0;

  // ========== Border Radius ==========

  static const double radiusXS = 2.0;
  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  static const double radius2XL = 20.0;
  static const double radiusFull = 999.0;

  // ========== Elevation / Shadows ==========

  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationSM = 2.0;
  static const double elevationMD = 4.0;
  static const double elevationLG = 8.0;
  static const double elevationXL = 12.0;
  static const double elevation2XL = 16.0;

  // ========== Icon Sizes ==========

  static const double iconSizeXS = 16.0;
  static const double iconSizeSM = 20.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 32.0;
  static const double iconSizeXL = 40.0;
  static const double iconSize2XL = 48.0;

  // ========== Animation Durations ==========

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);

  // ========== Breakpoints ==========

  static const double breakpointMobile = 480.0;
  static const double breakpointTablet = 768.0;
  static const double breakpointDesktop = 1024.0;
  static const double breakpointWide = 1440.0;

  // ========== Custom Gradients ==========

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========== Semantic Spacing ==========

  /// Spacing for different UI components
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(
    horizontal: spaceBase,
    vertical: spaceMD,
  );

  static const EdgeInsets paddingCard = EdgeInsets.all(spaceBase);

  static const EdgeInsets paddingScreen = EdgeInsets.all(spaceBase);

  static const EdgeInsets marginBottomSmall = EdgeInsets.only(bottom: spaceSM);
  static const EdgeInsets marginBottomMedium = EdgeInsets.only(
    bottom: spaceBase,
  );
  static const EdgeInsets marginBottomLarge = EdgeInsets.only(bottom: spaceXL);

  // ========== Status Colors ==========

  /// Order status colors
  static const Color statusPending = Color(0xFFFF9800); // Orange
  static const Color statusAccepted = Color(0xFF2196F3); // Blue
  static const Color statusInProgress = Color(0xFF9C27B0); // Purple
  static const Color statusCompleted = Color(0xFF4CAF50); // Green
  static const Color statusCancelled = Color(0xFFF44336); // Red
  static const Color statusRejected = Color(0xFFFF5252); // Light Red

  /// Get color for order status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'accepted':
        return statusAccepted;
      case 'in_progress':
      case 'inprogress':
        return statusInProgress;
      case 'completed':
        return statusCompleted;
      case 'cancelled':
        return statusCancelled;
      case 'rejected':
        return statusRejected;
      default:
        return neutral500;
    }
  }
}
