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

    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: DesignTokens.primaryBlue,
      primaryContainer: DesignTokens.primaryBlueLight,
      secondary: DesignTokens.accentOrange,
      secondaryContainer: Color(0xFFFFCC80),
      surface: DesignTokens.surfaceLight,
      error: DesignTokens.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: DesignTokens.neutral900,
      onError: Colors.white,
    ),

    // Scaffold
    scaffoldBackgroundColor: DesignTokens.backgroundLight,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: DesignTokens.backgroundLight,
      foregroundColor: DesignTokens.neutral900,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: DesignTokens.fontSizeLG,
        fontWeight: DesignTokens.fontWeightSemiBold,
        color: DesignTokens.neutral900,
      ),
      iconTheme: IconThemeData(
        color: DesignTokens.neutral900,
        size: DesignTokens.iconSizeMD,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: DesignTokens.elevationSM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: DesignTokens.spaceSM),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: DesignTokens.paddingButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        elevation: DesignTokens.elevationSM,
        textStyle: TextStyle(
          fontSize: DesignTokens.fontSizeBase,
          fontWeight: DesignTokens.fontWeightMedium,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: DesignTokens.paddingButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        textStyle: TextStyle(
          fontSize: DesignTokens.fontSizeBase,
          fontWeight: DesignTokens.fontWeightMedium,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: DesignTokens.paddingButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        side: BorderSide(color: DesignTokens.primaryBlue, width: 1.5),
        textStyle: TextStyle(
          fontSize: DesignTokens.fontSizeBase,
          fontWeight: DesignTokens.fontWeightMedium,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DesignTokens.neutral100,
      contentPadding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceBase,
        vertical: DesignTokens.spaceMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide.none,
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
      ),
      displayMedium: TextStyle(
        fontSize: DesignTokens.fontSize3XL,
        fontWeight: DesignTokens.fontWeightBold,
        color: DesignTokens.neutral900,
      ),
      headlineLarge: TextStyle(
        fontSize: DesignTokens.fontSize2XL,
        fontWeight: DesignTokens.fontWeightSemiBold,
        color: DesignTokens.neutral900,
      ),
      headlineMedium: TextStyle(
        fontSize: DesignTokens.fontSizeXL,
        fontWeight: DesignTokens.fontWeightSemiBold,
        color: DesignTokens.neutral900,
      ),
      titleLarge: TextStyle(
        fontSize: DesignTokens.fontSizeLG,
        fontWeight: DesignTokens.fontWeightMedium,
        color: DesignTokens.neutral900,
      ),
      titleMedium: TextStyle(
        fontSize: DesignTokens.fontSizeMD,
        fontWeight: DesignTokens.fontWeightMedium,
        color: DesignTokens.neutral900,
      ),
      bodyLarge: TextStyle(
        fontSize: DesignTokens.fontSizeMD,
        fontWeight: DesignTokens.fontWeightRegular,
        color: DesignTokens.neutral800,
      ),
      bodyMedium: TextStyle(
        fontSize: DesignTokens.fontSizeBase,
        fontWeight: DesignTokens.fontWeightRegular,
        color: DesignTokens.neutral800,
      ),
      bodySmall: TextStyle(
        fontSize: DesignTokens.fontSizeSM,
        fontWeight: DesignTokens.fontWeightRegular,
        color: DesignTokens.neutral700,
      ),
      labelLarge: TextStyle(
        fontSize: DesignTokens.fontSizeBase,
        fontWeight: DesignTokens.fontWeightMedium,
        color: DesignTokens.neutral900,
      ),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: DesignTokens.neutral200,
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
      backgroundColor: DesignTokens.neutral100,
      deleteIconColor: DesignTokens.neutral600,
      labelStyle: TextStyle(
        fontSize: DesignTokens.fontSizeSM,
        color: DesignTokens.neutral800,
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

  // ========== Dark Theme ==========

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: DesignTokens.primaryBlueLight,
      primaryContainer: DesignTokens.primaryBlueDark,
      secondary: DesignTokens.accentOrange,
      secondaryContainer: Color(0xFFF57C00),
      surface: DesignTokens.surfaceDark,
      error: DesignTokens.error,
      onPrimary: DesignTokens.neutral900,
      onSecondary: Colors.white,
      onSurface: DesignTokens.neutral50,
      onError: Colors.white,
    ),

    // Scaffold
    scaffoldBackgroundColor: DesignTokens.backgroundDark,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: DesignTokens.surfaceDark,
      foregroundColor: DesignTokens.neutral50,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: DesignTokens.fontSizeLG,
        fontWeight: DesignTokens.fontWeightSemiBold,
        color: DesignTokens.neutral50,
      ),
      iconTheme: IconThemeData(
        color: DesignTokens.neutral50,
        size: DesignTokens.iconSizeMD,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: DesignTokens.elevationSM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
      ),
      color: DesignTokens.surfaceDark,
      margin: const EdgeInsets.symmetric(vertical: DesignTokens.spaceSM),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: DesignTokens.paddingButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        elevation: DesignTokens.elevationSM,
        textStyle: TextStyle(
          fontSize: DesignTokens.fontSizeBase,
          fontWeight: DesignTokens.fontWeightMedium,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: DesignTokens.paddingButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        textStyle: TextStyle(
          fontSize: DesignTokens.fontSizeBase,
          fontWeight: DesignTokens.fontWeightMedium,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: DesignTokens.paddingButton,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        ),
        side: BorderSide(color: DesignTokens.primaryBlueLight, width: 1.5),
        textStyle: TextStyle(
          fontSize: DesignTokens.fontSizeBase,
          fontWeight: DesignTokens.fontWeightMedium,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      contentPadding: EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceBase,
        vertical: DesignTokens.spaceMD,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        borderSide: BorderSide.none,
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
      ),
      displayMedium: TextStyle(
        fontSize: DesignTokens.fontSize3XL,
        fontWeight: DesignTokens.fontWeightBold,
        color: DesignTokens.neutral50,
      ),
      headlineLarge: TextStyle(
        fontSize: DesignTokens.fontSize2XL,
        fontWeight: DesignTokens.fontWeightSemiBold,
        color: DesignTokens.neutral50,
      ),
      headlineMedium: TextStyle(
        fontSize: DesignTokens.fontSizeXL,
        fontWeight: DesignTokens.fontWeightSemiBold,
        color: DesignTokens.neutral50,
      ),
      titleLarge: TextStyle(
        fontSize: DesignTokens.fontSizeLG,
        fontWeight: DesignTokens.fontWeightMedium,
        color: DesignTokens.neutral50,
      ),
      titleMedium: TextStyle(
        fontSize: DesignTokens.fontSizeMD,
        fontWeight: DesignTokens.fontWeightMedium,
        color: DesignTokens.neutral50,
      ),
      bodyLarge: TextStyle(
        fontSize: DesignTokens.fontSizeMD,
        fontWeight: DesignTokens.fontWeightRegular,
        color: DesignTokens.neutral100,
      ),
      bodyMedium: TextStyle(
        fontSize: DesignTokens.fontSizeBase,
        fontWeight: DesignTokens.fontWeightRegular,
        color: DesignTokens.neutral100,
      ),
      bodySmall: TextStyle(
        fontSize: DesignTokens.fontSizeSM,
        fontWeight: DesignTokens.fontWeightRegular,
        color: DesignTokens.neutral300,
      ),
      labelLarge: TextStyle(
        fontSize: DesignTokens.fontSizeBase,
        fontWeight: DesignTokens.fontWeightMedium,
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
      color: DesignTokens.neutral300,
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



