// File: lib/theme/app_theme.dart
// Purpose: Define light and dark themes for the application using design tokens.

import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppTheme {
  // Prevent instantiation
  AppTheme._();

  // ========== Light Theme ==========

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: DesignTokens.fontFamily,

    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: DesignTokens.primaryBlue,
      primaryContainer: DesignTokens.primaryBlueLight.withValues(alpha: 0.2),
      secondary: DesignTokens.accentOrange,
      secondaryContainer: DesignTokens.accentOrange.withValues(alpha: 0.1),
      surface: DesignTokens.surfaceLight,
      error: DesignTokens.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: DesignTokens.neutral900,
      onSurfaceVariant: DesignTokens.neutral600,
      onError: Colors.white,
      outline: DesignTokens.neutral200,
    ),

    // Scaffold
    scaffoldBackgroundColor: DesignTokens.backgroundLight,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: DesignTokens.backgroundLight,
      foregroundColor: DesignTokens.neutral900,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: DesignTokens.fontFamily,
        fontSize: DesignTokens.fontSizeLG,
        fontWeight: DesignTokens.fontWeightBold,
        color: DesignTokens.neutral900,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(
        color: DesignTokens.neutral900,
        size: DesignTokens.iconSizeMD,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        side: BorderSide(color: DesignTokens.neutral200, width: 1),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: DesignTokens.spaceSM),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style:
          ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: DesignTokens.primaryBlue,
            padding: DesignTokens.paddingButton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
            ),
            elevation: 0,
            textStyle: TextStyle(
              fontFamily: DesignTokens.fontFamily,
              fontSize: DesignTokens.fontSizeBase,
              fontWeight: DesignTokens.fontWeightSemiBold,
              letterSpacing: 0.2,
            ),
          ).copyWith(
            elevation: WidgetStateProperty.resolveWith<double>((states) {
              if (states.contains(WidgetState.pressed)) return 0;
              if (states.contains(WidgetState.hovered)) return 2;
              return 0;
            }),
          ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: DesignTokens.paddingButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        side: BorderSide(color: DesignTokens.neutral200, width: 1.5),
        foregroundColor: DesignTokens.neutral900,
        textStyle: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: DesignTokens.fontSizeBase,
          fontWeight: DesignTokens.fontWeightSemiBold,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceBase,
        vertical: DesignTokens.spaceMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide(color: DesignTokens.neutral200, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide(color: DesignTokens.neutral200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide(color: DesignTokens.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide(color: DesignTokens.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide(color: DesignTokens.error, width: 2),
      ),
      labelStyle: TextStyle(
        fontSize: DesignTokens.fontSizeBase,
        color: DesignTokens.neutral600,
        fontWeight: DesignTokens.fontWeightMedium,
      ),
      hintStyle: TextStyle(
        fontSize: DesignTokens.fontSizeBase,
        color: DesignTokens.neutral400,
      ),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: DesignTokens.fontSize4XL,
        fontWeight: DesignTokens.fontWeightBold,
        color: DesignTokens.neutral900,
        letterSpacing: -1.0,
      ),
      displayMedium: TextStyle(
        fontSize: DesignTokens.fontSize3XL,
        fontWeight: DesignTokens.fontWeightBold,
        color: DesignTokens.neutral900,
        letterSpacing: -0.8,
      ),
      headlineLarge: TextStyle(
        fontSize: DesignTokens.fontSize2XL,
        fontWeight: DesignTokens.fontWeightBold,
        color: DesignTokens.neutral900,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: DesignTokens.fontSizeXL,
        fontWeight: DesignTokens.fontWeightSemiBold,
        color: DesignTokens.neutral900,
      ),
      titleLarge: TextStyle(
        fontSize: DesignTokens.fontSizeLG,
        fontWeight: DesignTokens.fontWeightSemiBold,
        color: DesignTokens.neutral900,
      ),
      titleMedium: TextStyle(
        fontSize: DesignTokens.fontSizeMD,
        fontWeight: DesignTokens.fontWeightMedium,
        color: DesignTokens.neutral800,
      ),
      bodyLarge: TextStyle(
        fontSize: DesignTokens.fontSizeMD,
        fontWeight: DesignTokens.fontWeightRegular,
        color: DesignTokens.neutral700,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: DesignTokens.fontSizeBase,
        fontWeight: DesignTokens.fontWeightRegular,
        color: DesignTokens.neutral600,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: DesignTokens.fontSizeSM,
        fontWeight: DesignTokens.fontWeightRegular,
        color: DesignTokens.neutral500,
      ),
      labelLarge: TextStyle(
        fontSize: DesignTokens.fontSizeBase,
        fontWeight: DesignTokens.fontWeightSemiBold,
        color: DesignTokens.neutral900,
      ),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: DesignTokens.neutral200,
      thickness: 1,
      space: DesignTokens.spaceBase,
    ),
  );

  // ========== Dark Theme ==========

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: DesignTokens.fontFamily,

    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: DesignTokens.primaryBlueLight,
      primaryContainer: DesignTokens.primaryBlueDark,
      secondary: DesignTokens.accentOrange,
      secondaryContainer: DesignTokens.accentOrange.withValues(alpha: 0.2),
      surface: DesignTokens.surfaceDark,
      error: DesignTokens.error,
      onPrimary: DesignTokens.neutral900,
      onSecondary: Colors.white,
      onSurface: DesignTokens.neutral50,
      onSurfaceVariant: DesignTokens.neutral400,
      onError: Colors.white,
      outline: DesignTokens.neutral700,
    ),

    // Scaffold
    scaffoldBackgroundColor: DesignTokens.backgroundDark,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: DesignTokens.surfaceDark,
      foregroundColor: DesignTokens.neutral50,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: DesignTokens.fontFamily,
        fontSize: DesignTokens.fontSizeLG,
        fontWeight: DesignTokens.fontWeightBold,
        color: DesignTokens.neutral50,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(
        color: DesignTokens.neutral50,
        size: DesignTokens.iconSizeMD,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        side: BorderSide(color: DesignTokens.neutral800, width: 1),
      ),
      color: DesignTokens.surfaceDark,
      margin: const EdgeInsets.symmetric(vertical: DesignTokens.spaceSM),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: DesignTokens.neutral900,
        backgroundColor: DesignTokens.primaryBlueLight,
        padding: DesignTokens.paddingButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        elevation: 0,
        textStyle: TextStyle(
          fontFamily: DesignTokens.fontFamily,
          fontSize: DesignTokens.fontSizeBase,
          fontWeight: DesignTokens.fontWeightSemiBold,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1E293B),
      contentPadding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceBase,
        vertical: DesignTokens.spaceMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide(color: DesignTokens.neutral700, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide(color: DesignTokens.neutral700, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide(color: DesignTokens.primaryBlueLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide(color: DesignTokens.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide(color: DesignTokens.error, width: 2),
      ),
      labelStyle: TextStyle(
        fontSize: DesignTokens.fontSizeBase,
        color: DesignTokens.neutral400,
        fontWeight: DesignTokens.fontWeightMedium,
      ),
      hintStyle: TextStyle(
        fontSize: DesignTokens.fontSizeBase,
        color: DesignTokens.neutral600,
      ),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: DesignTokens.fontSize4XL,
        fontWeight: DesignTokens.fontWeightBold,
        color: DesignTokens.neutral50,
        letterSpacing: -1.0,
      ),
      displayMedium: TextStyle(
        fontSize: DesignTokens.fontSize3XL,
        fontWeight: DesignTokens.fontWeightBold,
        color: DesignTokens.neutral50,
        letterSpacing: -0.8,
      ),
      headlineLarge: TextStyle(
        fontSize: DesignTokens.fontSize2XL,
        fontWeight: DesignTokens.fontWeightBold,
        color: DesignTokens.neutral50,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: DesignTokens.fontSizeXL,
        fontWeight: DesignTokens.fontWeightSemiBold,
        color: DesignTokens.neutral50,
      ),
      titleLarge: TextStyle(
        fontSize: DesignTokens.fontSizeLG,
        fontWeight: DesignTokens.fontWeightSemiBold,
        color: DesignTokens.neutral50,
      ),
      titleMedium: TextStyle(
        fontSize: DesignTokens.fontSizeMD,
        fontWeight: DesignTokens.fontWeightMedium,
        color: DesignTokens.neutral100,
      ),
      bodyLarge: TextStyle(
        fontSize: DesignTokens.fontSizeMD,
        fontWeight: DesignTokens.fontWeightRegular,
        color: DesignTokens.neutral200,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: DesignTokens.fontSizeBase,
        fontWeight: DesignTokens.fontWeightRegular,
        color: DesignTokens.neutral300,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: DesignTokens.fontSizeSM,
        fontWeight: DesignTokens.fontWeightRegular,
        color: DesignTokens.neutral400,
      ),
      labelLarge: TextStyle(
        fontSize: DesignTokens.fontSizeBase,
        fontWeight: DesignTokens.fontWeightSemiBold,
        color: DesignTokens.neutral50,
      ),
    ),
    // Divider Theme
    dividerTheme: DividerThemeData(
      color: DesignTokens.neutral700,
      thickness: 1,
      space: DesignTokens.spaceBase,
    ),

    // Icon Theme
    iconTheme: IconThemeData(
      color: DesignTokens.neutral700,
      size: DesignTokens.iconSizeMD,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: DesignTokens.neutral800,
      deleteIconColor: DesignTokens.neutral400,
      labelStyle: TextStyle(
        fontSize: DesignTokens.fontSizeSM,
        color: DesignTokens.neutral100,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSM,
        vertical: DesignTokens.spaceXS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      ),
    ),
  );
}
