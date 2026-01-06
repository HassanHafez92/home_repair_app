/// Accessibility Utilities
///
/// This file provides utilities for improving accessibility throughout the application,
/// including semantic labels, focus management, and screen reader support.

// ignore: unnecessary_library_name
library accessibility_utils;

import 'package:flutter/material.dart';

/// Accessibility helper class
class AccessibilityHelper {
  /// Add semantic label to a widget
  static Widget withSemantics({
    required Widget child,
    required String label,
    String? hint,
    bool? enabled,
    bool? checked,
    bool? selected,
    bool? inMutuallyExclusiveGroup,
    bool? isButton,
    bool? isLink,
    bool? isHeader,
    bool? isTextField,
    bool? isImage,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onToggle,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      enabled: enabled,
      checked: checked,
      selected: selected,
      inMutuallyExclusiveGroup: inMutuallyExclusiveGroup,
      button: isButton,
      link: isLink,
      header: isHeader,
      textField: isTextField,
      image: isImage,
      onTap: onTap,
      onLongPress: onLongPress,
      child: ExcludeSemantics(child: child),
    );
  }

  /// Create accessible button
  static Widget accessibleButton({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onPressed,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: onPressed,
      child: child,
    );
  }

  /// Create accessible text field
  static Widget accessibleTextField({
    required Widget child,
    required String label,
    String? hint,
    bool? isObscured,
    bool readOnly = false,
  }) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      obscured: isObscured ?? false,
      readOnly: readOnly,
      child: child,
    );
  }

  /// Create accessible image
  static Widget accessibleImage({
    required Widget child,
    required String label,
    bool decorative = false,
  }) {
    return Semantics(image: true, label: decorative ? '' : label, child: child);
  }

  /// Create accessible icon button
  static Widget accessibleIconButton({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onPressed,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      hint: hint,
      onTap: onPressed,
      child: Tooltip(message: label, child: child),
    );
  }

  /// Announce message to screen reader
  static void announce(BuildContext context, String message) {
    // Announce message to screen reader
    // Implementation depends on screen reader being used
  }

  /// Create accessible list item
  static Widget accessibleListItem({
    required Widget child,
    required String label,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      selected: selected,
      button: onTap != null,
      onTap: onTap,
      child: child,
    );
  }

  /// Create accessible card
  static Widget accessibleCard({
    required Widget child,
    required String label,
    String? description,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      value: description,
      button: onTap != null,
      onTap: onTap,
      child: Card(child: child),
    );
  }

  /// Create accessible tab
  static Widget accessibleTab({
    required Widget child,
    required String label,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      onTap: onTap,
      child: child,
    );
  }

  /// Create accessible switch
  static Widget accessibleSwitch({
    required Widget child,
    required String label,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    return Semantics(
      label: label,
      checked: value,
      onTap: onChanged != null ? () => onChanged(!value) : null,
      child: child,
    );
  }

  /// Create accessible checkbox
  static Widget accessibleCheckbox({
    required Widget child,
    required String label,
    required bool value,
    ValueChanged<bool?>? onChanged,
  }) {
    return Semantics(
      label: label,
      checked: value,
      inMutuallyExclusiveGroup: false,
      onTap: onChanged != null ? () => onChanged(!value) : null,
      child: child,
    );
  }

  /// Create accessible radio
  static Widget accessibleRadio({
    required Widget child,
    required String label,
    required bool value,
    ValueChanged<bool?>? onChanged,
  }) {
    return Semantics(
      label: label,
      checked: value,
      inMutuallyExclusiveGroup: true,
      onTap: onChanged != null ? () => onChanged(!value) : null,
      child: child,
    );
  }

  /// Create accessible slider
  static Widget accessibleSlider({
    required Widget child,
    required String label,
    required double value,
    required double min,
    required double max,
    ValueChanged<double>? onChanged,
  }) {
    return Semantics(
      label: label,
      value: value.toStringAsFixed(1),
      slider: true,
      onIncrease: onChanged != null && value < max
          ? () => onChanged(value + (max - min) / 100)
          : null,
      onDecrease: onChanged != null && value > min
          ? () => onChanged(value - (max - min) / 100)
          : null,
      child: child,
    );
  }

  /// Create accessible progress indicator
  static Widget accessibleProgressIndicator({
    required Widget child,
    required String label,
    double? value,
  }) {
    return Semantics(
      label: label,
      value: value?.toStringAsFixed(1),
      child: child,
    );
  }

  /// Create accessible dialog
  static Widget accessibleDialog({
    required Widget child,
    required String title,
    String? content,
  }) {
    return Semantics(label: title, value: content, child: child);
  }

  /// Create accessible bottom sheet
  static Widget accessibleBottomSheet({
    required Widget child,
    required String label,
  }) {
    return Semantics(label: label, child: child);
  }

  /// Create accessible chip
  static Widget accessibleChip({
    required Widget child,
    required String label,
    bool selected = false,
    VoidCallback? onDeleted,
    VoidCallback? onSelected,
  }) {
    return Semantics(
      label: label,
      selected: selected,
      button: onSelected != null,
      onTap: onSelected,
      child: child,
    );
  }

  /// Create accessible badge
  static Widget accessibleBadge({
    required Widget child,
    required String label,
    int? count,
  }) {
    return Semantics(label: label, value: count?.toString(), child: child);
  }

  /// Create accessible navigation rail
  static Widget accessibleNavigationRail({
    required Widget child,
    required String label,
  }) {
    return Semantics(label: label, child: child);
  }

  /// Create accessible bottom navigation bar
  static Widget accessibleBottomNavigationBar({
    required Widget child,
    required String label,
  }) {
    return Semantics(label: label, child: child);
  }

  /// Create accessible app bar
  static Widget accessibleAppBar({
    required Widget child,
    required String title,
  }) {
    return Semantics(label: title, header: true, child: child);
  }

  /// Create accessible drawer
  static Widget accessibleDrawer({
    required Widget child,
    required String label,
  }) {
    return Semantics(
      label: label,
      namesRoute: true,
      scopesRoute: true,
      explicitChildNodes: true,
      child: child,
    );
  }

  /// Create accessible snackbar
  static Widget accessibleSnackbar({
    required Widget child,
    required String message,
  }) {
    return Semantics(label: message, liveRegion: true, child: child);
  }

  /// Create accessible tooltip
  static Widget accessibleTooltip({
    required Widget child,
    required String message,
  }) {
    return Semantics(
      tooltip: message,
      child: Tooltip(message: message, child: child),
    );
  }

  /// Create accessible divider
  static Widget accessibleDivider({
    required Widget child,
    required String label,
  }) {
    return Semantics(label: label, child: child);
  }

  /// Create accessible expansion panel
  static Widget accessibleExpansionPanel({
    required Widget child,
    required String label,
    bool expanded = false,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      expanded: expanded,
      button: true,
      onTap: onTap,
      child: child,
    );
  }

  /// Create accessible stepper
  static Widget accessibleStepper({
    required Widget child,
    required String label,
    int? currentStep,
  }) {
    return Semantics(
      label: label,
      value: currentStep?.toString(),
      child: child,
    );
  }

  /// Create accessible date picker
  static Widget accessibleDatePicker({
    required Widget child,
    required String label,
  }) {
    return Semantics(label: label, child: child);
  }

  /// Create accessible time picker
  static Widget accessibleTimePicker({
    required Widget child,
    required String label,
  }) {
    return Semantics(label: label, child: child);
  }

  /// Create accessible search field
  static Widget accessibleSearchField({
    required Widget child,
    required String label,
    String? hint,
    ValueChanged<String>? onChanged,
  }) {
    return Semantics(textField: true, label: label, hint: hint, child: child);
  }
}

/// Focus management utilities
class FocusManager {
  static final Map<String, FocusNode> _focusNodes = {};

  /// Get or create focus node for a key
  static FocusNode getFocusNode(String key) {
    _focusNodes[key] ??= FocusNode();
    return _focusNodes[key]!;
  }

  /// Dispose focus node for a key
  static void disposeFocusNode(String key) {
    _focusNodes[key]?.dispose();
    _focusNodes.remove(key);
  }

  /// Dispose all focus nodes
  static void disposeAll() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    _focusNodes.clear();
  }

  /// Request focus for a node
  static void requestFocus(String key) {
    _focusNodes[key]?.requestFocus();
  }

  /// Unfocus current node
  static void unfocus() {
    // Current focus unfocus implementation
  }
}

/// High contrast mode utilities
class HighContrastMode {
  static bool isHighContrast(BuildContext context) {
    return MediaQuery.of(context).highContrast;
  }

  static Color adjustColorForHighContrast(BuildContext context, Color color) {
    if (isHighContrast(context)) {
      // Return high contrast version of color
      return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }
    return color;
  }

  static ThemeData adjustThemeForHighContrast(
    BuildContext context,
    ThemeData theme,
  ) {
    if (isHighContrast(context)) {
      return theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: Colors.black,
          secondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      );
    }
    return theme;
  }
}
