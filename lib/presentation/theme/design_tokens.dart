// File: lib/theme/design_tokens.dart
// Purpose: Design system tokens for consistent styling across the app

import 'package:flutter/material.dart';

/// Design tokens for the Home Repair App
/// Use these tokens instead of hard-coded values for consistency
class DesignTokens {
  // Prevent instantiation
  DesignTokens._();

  // ========== Color Palette ==========

  /// Primary brand colors - Modern Indigo palette
  static const Color primaryBlue = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryBlueDark = Color(0xFF4338CA); // Indigo 700
  static const Color primaryBlueLight = Color(0xFF818CF8); // Indigo 400

  /// Accent colors
  static const Color accentOrange = Color(0xFFF59E0B); // Amber 500
  static const Color accentGreen = Color(0xFF10B981); // Emerald 500
  static const Color accentRed = Color(0xFFEF4444); // Red 500

  /// Fixawy brand colors - For service category styling
  static const Color fixawyYellow = Color(0xFFFCB712); // Primary accent
  static const Color fixawyYellowLight = Color(0xFFFFF3CD); // Light variant
  static const Color fixawyNavy = Color(0xFF1B2945); // Dark sections/footer
  static const Color fixawyBackground = Color(0xFFF8F9FA); // Page background

  /// Neutral colors - Slate palette for premium feel
  static const Color neutral900 = Color(0xFF0F172A);
  static const Color neutral800 = Color(0xFF1E293B);
  static const Color neutral700 = Color(0xFF334155);
  static const Color neutral600 = Color(0xFF475569);
  static const Color neutral500 = Color(0xFF64748B);
  static const Color neutral400 = Color(0xFF94A3B8);
  static const Color neutral300 = Color(0xFFCBD5E1);
  static const Color neutral200 = Color(0xFFE2E8F0);
  static const Color neutral100 = Color(0xFFF1F5F9);
  static const Color neutral50 = Color(0xFFF8FAFC);

  /// Semantic colors
  static const Color success = accentGreen;
  static const Color warning = accentOrange;
  static const Color error = accentRed;
  static const Color info = primaryBlue;

  /// Background colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);

  // ========== Glassmorphism ==========

  /// Blur values for glassmorphism effects
  static const double blurSM = 8.0;
  static const double blurMD = 16.0;
  static const double blurLG = 24.0;
  static const double blurXL = 40.0;

  /// Overlay colors for glass effect
  static Color glassLight = Colors.white.withValues(alpha: 0.7);
  static Color glassDark = neutral900.withValues(alpha: 0.6);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);

  /// Surface tints for elevation hierarchy
  static Color surfaceTint1 = primaryBlue.withValues(alpha: 0.02);
  static Color surfaceTint2 = primaryBlue.withValues(alpha: 0.04);
  static Color surfaceTint3 = primaryBlue.withValues(alpha: 0.06);

  // ========== Typography ==========

  /// Font family - Modern, premium font
  static const String fontFamily = 'Outfit';

  /// Font sizes
  static const double fontSizeXS = 12.0;
  static const double fontSizeSM = 13.0;
  static const double fontSizeBase = 15.0;
  static const double fontSizeMD = 17.0;
  static const double fontSizeLG = 19.0;
  static const double fontSizeXL = 22.0;
  static const double fontSize2XL = 28.0;
  static const double fontSize3XL = 34.0;
  static const double fontSize4XL = 42.0;

  /// Font weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  /// Line heights
  static const double lineHeightTight = 1.1;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.8;

  // ========== Spacing ==========

  static const double spaceXXS = 4.0;
  static const double spaceXS = 6.0;
  static const double spaceSM = 10.0;
  static const double spaceMD = 14.0;
  static const double spaceBase = 18.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double space2XL = 40.0;
  static const double space3XL = 56.0;
  static const double space4XL = 72.0;

  // ========== Border Radius ==========

  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 18.0;
  static const double radiusXL = 24.0;
  static const double radius2XL = 32.0;
  static const double radiusFull = 999.0;

  // ========== Elevation / Shadows ==========

  static const double elevationNone = 0.0;
  static const double elevationXS = 1.0;
  static const double elevationSM = 3.0;
  static const double elevationMD = 6.0;
  static const double elevationLG = 12.0;
  static const double elevationXL = 20.0;
  static const double elevation2XL = 30.0;

  /// Premium soft shadows
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: neutral900.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: neutral900.withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Lifted shadow - for cards that need emphasis
  static List<BoxShadow> shadowLifted = [
    BoxShadow(
      color: neutral900.withValues(alpha: 0.08),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: primaryBlue.withValues(alpha: 0.06),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  /// Colored shadows for accent elements
  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: primaryBlue.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> shadowSuccess = [
    BoxShadow(
      color: accentGreen.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> shadowWarning = [
    BoxShadow(
      color: accentOrange.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ========== Icon Sizes ==========

  static const double iconSizeXS = 16.0;
  static const double iconSizeSM = 20.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 32.0;
  static const double iconSizeXL = 40.0;
  static const double iconSize2XL = 48.0;

  // ========== Animation Durations ==========

  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 400);
  static const Duration durationSlow = Duration(milliseconds: 600);

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
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradients for variety
  static const LinearGradient accentGradientPurple = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradientPink = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradientTeal = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle background gradients
  static const LinearGradient backgroundGradientLight = LinearGradient(
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient backgroundGradientDark = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ========== Semantic Spacing ==========

  /// Spacing for different UI components
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(
    horizontal: spaceLG,
    vertical: spaceBase,
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
  static const Color statusPending = Color(0xFFF59E0B); // Amber
  static const Color statusAccepted = Color(0xFF6366F1); // Indigo
  static const Color statusInProgress = Color(0xFF8B5CF6); // Violet
  static const Color statusCompleted = Color(0xFF10B981); // Emerald
  static const Color statusCancelled = Color(0xFFEF4444); // Red
  static const Color statusRejected = Color(0xFFF43F5E); // Rose

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
