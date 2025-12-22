import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

enum ButtonVariant { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.width,
    this.height = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on variant
    Color backgroundColor;
    Color foregroundColor;
    BorderSide? borderSide;
    double elevation = 0;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = colorScheme.primary;
        foregroundColor = Colors.white;
        elevation = 0;
        break;
      case ButtonVariant.secondary:
        backgroundColor = colorScheme.secondary;
        foregroundColor = Colors.white;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.primary;
        borderSide = BorderSide(color: colorScheme.primary, width: 1.5);
        break;
      case ButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = colorScheme.primary;
        break;
    }

    // Disable colors if onPressed is null (disabled state)
    if (onPressed == null) {
      backgroundColor = DesignTokens.neutral200;
      foregroundColor = DesignTokens.neutral400;
      borderSide = null;
    }

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: isLoading ? '$text, loading' : text,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style:
              ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                elevation: elevation,
                side: borderSide,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceLG,
                ),
                textStyle: theme.textTheme.labelLarge?.copyWith(
                  fontSize: DesignTokens.fontSizeBase,
                  fontWeight: DesignTokens.fontWeightSemiBold,
                  letterSpacing: 0.5,
                ),
              ).copyWith(
                elevation: WidgetStateProperty.resolveWith<double>((states) {
                  if (variant == ButtonVariant.primary) {
                    if (states.contains(WidgetState.pressed)) return 0;
                    if (states.contains(WidgetState.hovered)) return 2;
                  }
                  return 0;
                }),
              ),
          child: isLoading
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: DesignTokens.iconSizeSM),
                      const SizedBox(width: DesignTokens.spaceSM),
                    ],
                    Text(text),
                  ],
                ),
        ),
      ),
    );
  }
}
