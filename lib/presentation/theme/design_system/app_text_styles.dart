/// Design System - Typography
///
/// This file defines the complete typography system for the application.
/// All text styles should be referenced from here to ensure consistency.
library;

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Font families used in the application
class AppFontFamilies {
  static const String primary = 'Roboto';
  static const String secondary = 'Open Sans';
}

/// Text styles organized by usage
class AppTextStyles {
  // Display styles - Large, expressive text
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.primary,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.primary,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.primary,
  );

  // Headline styles - High-emphasis headings
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.primary,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.primary,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.primary,
  );

  // Title styles - Medium-emphasis headings
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.primary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.primary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.primary,
  );

  // Body styles - Main content text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.primary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.primary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.secondary,
  );

  // Label styles - Buttons, tabs, and other UI elements
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.primary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.primary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.secondary,
  );

  // Helper methods for creating colored variants
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  // Specialized text styles for specific use cases
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.inverse,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.secondary,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.tertiary,
  );

  // Error and success text styles
  static const TextStyle error = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: AppFontFamilies.primary,
    color: SemanticColors.error,
  );

  static const TextStyle success = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: AppFontFamilies.primary,
    color: SemanticColors.success,
  );

  // Link text style
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: AppFontFamilies.primary,
    color: TextColors.link,
    decoration: TextDecoration.underline,
  );
}

/// Text theme for Material app
class AppTextTheme {
  static TextTheme get lightTextTheme {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    );
  }

  static TextTheme get darkTextTheme {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: TextColors.inverse,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: TextColors.inverse,
      ),
      displaySmall: AppTextStyles.displaySmall.copyWith(
        color: TextColors.inverse,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: TextColors.inverse,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: TextColors.inverse,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: TextColors.inverse,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(color: TextColors.inverse),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: TextColors.inverse,
      ),
      titleSmall: AppTextStyles.titleSmall.copyWith(color: TextColors.inverse),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: TextColors.inverse),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: TextColors.inverse),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: TextColors.secondary),
      labelLarge: AppTextStyles.labelLarge.copyWith(color: TextColors.inverse),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: TextColors.inverse,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: TextColors.secondary,
      ),
    );
  }
}
