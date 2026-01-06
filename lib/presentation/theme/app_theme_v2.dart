// ignore: dangling_library_doc_comments
/// Enhanced App Theme with Design System Integration
///
/// This file provides an enhanced theme system that integrates with the new
/// design system while maintaining compatibility with existing DesignTokens.
///
/// Usage:
/// - For new components, use the design system exports from design_system.dart
/// - For existing components, continue using DesignTokens
/// - Gradually migrate to design system components over time

import 'package:flutter/material.dart';
import 'design_tokens.dart';
import 'design_system/design_system.dart';

class AppThemeV2 {
  // Prevent instantiation
  AppThemeV2._();

  // ========== Light Theme ==========

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: DesignTokens.fontFamily,

      // Color Scheme - Using design system colors
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight.withValues(alpha: 0.2),
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight.withValues(alpha: 0.1),
        surface: SurfaceColors.surface,
        error: SemanticColors.error,
        onPrimary: TextColors.inverse,
        onSecondary: TextColors.inverse,
        onSurface: TextColors.primary,
        onSurfaceVariant: TextColors.secondary,
        onError: TextColors.inverse,
        outline: BorderColors.default_,
      ),

      // Scaffold
      scaffoldBackgroundColor: NeutralColors.gray50,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: SurfaceColors.surface,
        foregroundColor: TextColors.primary,
        elevation: AppElevation.none,
        scrolledUnderElevation: AppElevation.xs,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineSmall,
        iconTheme: IconThemeData(color: TextColors.primary, size: 24),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppElevation.none,
        shape: AppShapeBorders.roundedRectangle(
          borderRadius: AppBorderRadius.lg,
        ),
        color: SurfaceColors.surface,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              foregroundColor: TextColors.inverse,
              backgroundColor: AppColors.primary,
              padding: AppEdgeInsets.button,
              shape: AppShapeBorders.roundedRectangle(
                borderRadius: AppBorderRadius.button,
              ),
              elevation: AppElevation.none,
              textStyle: AppTextStyles.button,
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith<double>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return AppElevation.none;
                }
                if (states.contains(WidgetState.hovered)) {
                  return AppElevation.xs;
                }
                return AppElevation.none;
              }),
              overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return AppColors.primaryDark.withValues(alpha: 0.1);
                }
                if (states.contains(WidgetState.hovered)) {
                  return AppColors.primaryLight.withValues(alpha: 0.1);
                }
                return Colors.transparent;
              }),
            ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              padding: AppEdgeInsets.button,
              shape: AppShapeBorders.roundedRectangle(
                borderRadius: AppBorderRadius.button,
              ),
              side: BorderSide(color: BorderColors.default_, width: 1.5),
              foregroundColor: TextColors.primary,
              textStyle: AppTextStyles.button,
            ).copyWith(
              side: WidgetStateProperty.resolveWith<BorderSide>((states) {
                if (states.contains(WidgetState.focused)) {
                  return BorderSide(color: AppColors.primary, width: 2);
                }
                if (states.contains(WidgetState.pressed)) {
                  return BorderSide(color: AppColors.primary, width: 1.5);
                }
                return BorderSide(color: BorderColors.default_, width: 1.5);
              }),
            ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              padding: AppEdgeInsets.button,
              shape: AppShapeBorders.roundedRectangle(
                borderRadius: AppBorderRadius.button,
              ),
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.button,
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return AppColors.primary.withValues(alpha: 0.1);
                }
                if (states.contains(WidgetState.hovered)) {
                  return AppColors.primary.withValues(alpha: 0.05);
                }
                return Colors.transparent;
              }),
            ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SurfaceColors.surface,
        contentPadding: AppEdgeInsets.input,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadiuses.allSmall,
          borderSide: BorderSide(color: BorderColors.default_, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadiuses.allSmall,
          borderSide: BorderSide(color: BorderColors.default_, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadiuses.allSmall,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadiuses.allSmall,
          borderSide: BorderSide(color: SemanticColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadiuses.allSmall,
          borderSide: BorderSide(color: SemanticColors.error, width: 2),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: TextColors.secondary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: TextColors.tertiary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: SemanticColors.error,
        ),
      ),

      // Text Theme - Using design system text styles
      textTheme: AppTextTheme.lightTextTheme,

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: BorderColors.light,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: TextColors.secondary, size: 24),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: TextColors.inverse,
        elevation: AppElevation.md,
        shape: const CircleBorder(),
        iconSize: 24,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: NeutralColors.gray100,
        deleteIconColor: TextColors.secondary,
        disabledColor: NeutralColors.gray200,
        selectedColor: AppColors.primary.withValues(alpha: 0.1),
        secondarySelectedColor: AppColors.secondary.withValues(alpha: 0.1),
        padding: AppEdgeInsets.horizontalSmall,
        labelStyle: AppTextStyles.labelMedium,
        secondaryLabelStyle: AppTextStyles.labelMedium,
        brightness: Brightness.light,
        shape: AppShapeBorders.stadium,
        side: BorderSide.none,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: SurfaceColors.surface,
        elevation: AppElevation.xxl,
        shape: AppShapeBorders.roundedRectangle(
          borderRadius: AppBorderRadius.lg,
        ),
        titleTextStyle: AppTextStyles.headlineSmall,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: SurfaceColors.surface,
        elevation: AppElevation.xxxl,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppBorderRadius.lg),
          ),
        ),
        modalBackgroundColor: SurfaceColors.surface,
        modalElevation: AppElevation.xxxl,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: NeutralColors.gray800,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: TextColors.inverse,
        ),
        shape: AppShapeBorders.roundedRectangle(
          borderRadius: AppBorderRadius.sm,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppElevation.md,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: SurfaceColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: TextColors.tertiary,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: AppElevation.md,
      ),
    );
  }

  // ========== Dark Theme ==========

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: DesignTokens.fontFamily,

      // Color Scheme - Using design system colors
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryLight,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondaryLight,
        secondaryContainer: AppColors.secondaryDark.withValues(alpha: 0.2),
        surface: NeutralColors.gray900,
        error: SemanticColors.errorLight,
        onPrimary: TextColors.primary,
        onSecondary: TextColors.inverse,
        onSurface: TextColors.inverse,
        onSurfaceVariant: TextColors.secondary,
        onError: TextColors.inverse,
        outline: NeutralColors.gray700,
      ),

      // Scaffold
      scaffoldBackgroundColor: NeutralColors.gray900,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: NeutralColors.gray900,
        foregroundColor: TextColors.inverse,
        elevation: AppElevation.none,
        scrolledUnderElevation: AppElevation.xs,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: TextColors.inverse,
        ),
        iconTheme: IconThemeData(color: TextColors.inverse, size: 24),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppElevation.none,
        shape: AppShapeBorders.roundedRectangle(
          borderRadius: AppBorderRadius.lg,
        ),
        color: NeutralColors.gray800,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style:
            ElevatedButton.styleFrom(
              foregroundColor: TextColors.primary,
              backgroundColor: AppColors.primaryLight,
              padding: AppEdgeInsets.button,
              shape: AppShapeBorders.roundedRectangle(
                borderRadius: AppBorderRadius.button,
              ),
              elevation: AppElevation.none,
              textStyle: AppTextStyles.button.copyWith(
                color: TextColors.primary,
              ),
            ).copyWith(
              elevation: WidgetStateProperty.resolveWith<double>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return AppElevation.none;
                }
                if (states.contains(WidgetState.hovered)) {
                  return AppElevation.xs;
                }
                return AppElevation.none;
              }),
              overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return AppColors.primary.withValues(alpha: 0.2);
                }
                if (states.contains(WidgetState.hovered)) {
                  return AppColors.primaryLight.withValues(alpha: 0.1);
                }
                return Colors.transparent;
              }),
            ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              padding: AppEdgeInsets.button,
              shape: AppShapeBorders.roundedRectangle(
                borderRadius: AppBorderRadius.button,
              ),
              side: BorderSide(color: NeutralColors.gray700, width: 1.5),
              foregroundColor: TextColors.inverse,
              textStyle: AppTextStyles.button.copyWith(
                color: TextColors.inverse,
              ),
            ).copyWith(
              side: WidgetStateProperty.resolveWith<BorderSide>((states) {
                if (states.contains(WidgetState.focused)) {
                  return BorderSide(color: AppColors.primaryLight, width: 2);
                }
                if (states.contains(WidgetState.pressed)) {
                  return BorderSide(color: AppColors.primaryLight, width: 1.5);
                }
                return BorderSide(color: NeutralColors.gray700, width: 1.5);
              }),
            ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style:
            TextButton.styleFrom(
              padding: AppEdgeInsets.button,
              shape: AppShapeBorders.roundedRectangle(
                borderRadius: AppBorderRadius.button,
              ),
              foregroundColor: AppColors.primaryLight,
              textStyle: AppTextStyles.button.copyWith(
                color: AppColors.primaryLight,
              ),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return AppColors.primaryLight.withValues(alpha: 0.2);
                }
                if (states.contains(WidgetState.hovered)) {
                  return AppColors.primaryLight.withValues(alpha: 0.1);
                }
                return Colors.transparent;
              }),
            ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeutralColors.gray800,
        contentPadding: AppEdgeInsets.input,
        border: OutlineInputBorder(
          borderRadius: AppBorderRadiuses.allSmall,
          borderSide: BorderSide(color: NeutralColors.gray700, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadiuses.allSmall,
          borderSide: BorderSide(color: NeutralColors.gray700, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadiuses.allSmall,
          borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadiuses.allSmall,
          borderSide: BorderSide(color: SemanticColors.errorLight, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppBorderRadiuses.allSmall,
          borderSide: BorderSide(color: SemanticColors.errorLight, width: 2),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: TextColors.secondary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: TextColors.tertiary,
        ),
        errorStyle: AppTextStyles.bodySmall.copyWith(
          color: SemanticColors.errorLight,
        ),
      ),

      // Text Theme - Using design system text styles
      textTheme: AppTextTheme.darkTextTheme,

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: NeutralColors.gray700,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: TextColors.secondary, size: 24),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: TextColors.primary,
        elevation: AppElevation.md,
        shape: const CircleBorder(),
        iconSize: 24,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: NeutralColors.gray800,
        deleteIconColor: TextColors.secondary,
        disabledColor: NeutralColors.gray700,
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        secondarySelectedColor: AppColors.secondary.withValues(alpha: 0.2),
        padding: AppEdgeInsets.horizontalSmall,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: TextColors.inverse,
        ),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: TextColors.inverse,
        ),
        brightness: Brightness.dark,
        shape: AppShapeBorders.stadium,
        side: BorderSide.none,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: NeutralColors.gray800,
        elevation: AppElevation.xxl,
        shape: AppShapeBorders.roundedRectangle(
          borderRadius: AppBorderRadius.lg,
        ),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: TextColors.inverse,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: TextColors.inverse,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: NeutralColors.gray800,
        elevation: AppElevation.xxxl,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppBorderRadius.lg),
          ),
        ),
        modalBackgroundColor: NeutralColors.gray800,
        modalElevation: AppElevation.xxxl,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: NeutralColors.gray700,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: TextColors.inverse,
        ),
        shape: AppShapeBorders.roundedRectangle(
          borderRadius: AppBorderRadius.sm,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: AppElevation.md,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NeutralColors.gray800,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: TextColors.tertiary,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: AppElevation.md,
      ),
    );
  }

  // ========== Theme Extensions ==========

  /// Custom theme properties that can be accessed via Theme.of(context).extension
  static ThemeData withExtensions(ThemeData theme) {
    return theme.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        _CustomThemeExtension(
          successColor: SemanticColors.success,
          warningColor: SemanticColors.warning,
          infoColor: SemanticColors.info,
        ),
      ],
    );
  }
}

/// Custom theme extension for additional properties
@immutable
class _CustomThemeExtension extends ThemeExtension<_CustomThemeExtension> {
  final Color successColor;
  final Color warningColor;
  final Color infoColor;

  const _CustomThemeExtension({
    required this.successColor,
    required this.warningColor,
    required this.infoColor,
  });

  @override
  _CustomThemeExtension copyWith({
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
  }) {
    return _CustomThemeExtension(
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
    );
  }

  @override
  _CustomThemeExtension lerp(
    ThemeExtension<_CustomThemeExtension>? other,
    double t,
  ) {
    if (other is! _CustomThemeExtension) {
      return this;
    }
    return _CustomThemeExtension(
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
    );
  }
}
