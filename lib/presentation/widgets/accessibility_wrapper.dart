/// Accessibility Wrapper
///
/// This widget provides accessibility features to ensure widgets meet
/// WCAG 2.1 accessibility standards.
library;

import 'package:flutter/material.dart';
import 'package:home_repair_app/presentation/utils/accessibility_utils.dart';

/// Accessibility wrapper widget
class AccessibilityWrapper extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final bool? button;
  final bool? link;
  final bool? header;
  final bool? textField;
  final bool? image;
  final bool? checked;
  final bool? selected;
  final bool? obscured;
  final bool? enabled;
  final bool? inMutuallyExclusiveGroup;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onToggle;
  final bool excludeSemantics;

  const AccessibilityWrapper({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.button,
    this.link,
    this.header,
    this.textField,
    this.image,
    this.checked,
    this.selected,
    this.obscured,
    this.enabled,
    this.inMutuallyExclusiveGroup,
    this.onTap,
    this.onLongPress,
    this.onToggle,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      link: link,
      header: header,
      textField: textField,
      image: image,
      checked: checked,
      selected: selected,
      obscured: obscured,
      enabled: enabled,
      inMutuallyExclusiveGroup: inMutuallyExclusiveGroup,
      onTap: onTap,
      onLongPress: onLongPress,
      child: excludeSemantics ? ExcludeSemantics(child: child) : child,
    );
  }
}

/// Accessible button widget
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final VoidCallback? onPressed;
  final bool enabled;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.accessibleButton(
      label: label,
      hint: hint,
      onPressed: onPressed,
      enabled: enabled,
      child: child,
    );
  }
}

/// Accessible text field widget
class AccessibleTextField extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final bool? isObscured;
  final bool readOnly;

  const AccessibleTextField({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.isObscured,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.accessibleTextField(
      label: label,
      hint: hint,
      isObscured: isObscured,
      readOnly: readOnly,
      child: child,
    );
  }
}

/// Accessible image widget
class AccessibleImage extends StatelessWidget {
  final Widget child;
  final String label;
  final bool decorative;

  const AccessibleImage({
    super.key,
    required this.child,
    required this.label,
    this.decorative = false,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.accessibleImage(
      label: label,
      decorative: decorative,
      child: child,
    );
  }
}

/// Accessible icon button widget
class AccessibleIconButton extends StatelessWidget {
  final Widget child;
  final String label;
  final String? hint;
  final VoidCallback? onPressed;
  final bool enabled;

  const AccessibleIconButton({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.accessibleIconButton(
      label: label,
      hint: hint,
      onPressed: onPressed,
      enabled: enabled,
      child: child,
    );
  }
}

/// Accessible card widget
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String label;
  final String? description;
  final VoidCallback? onTap;

  const AccessibleCard({
    super.key,
    required this.child,
    required this.label,
    this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.accessibleCard(
      label: label,
      description: description,
      onTap: onTap,
      child: Card(child: child),
    );
  }
}

/// Accessible list tile widget
class AccessibleListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final String label;
  final String? hint;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AccessibleListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    required this.label,
    this.hint,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.accessibleListItem(
      label: label,
      selected: selected,
      onTap: onTap,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}

/// Accessible switch widget
class AccessibleSwitch extends StatelessWidget {
  final Widget child;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AccessibleSwitch({
    super.key,
    required this.child,
    required this.label,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.accessibleSwitch(
      label: label,
      value: value,
      onChanged: onChanged,
      child: child,
    );
  }
}

/// Accessible checkbox widget
class AccessibleCheckbox extends StatelessWidget {
  final Widget child;
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const AccessibleCheckbox({
    super.key,
    required this.child,
    required this.label,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.accessibleCheckbox(
      label: label,
      value: value,
      onChanged: onChanged,
      child: child,
    );
  }
}

/// Accessible radio widget
class AccessibleRadio extends StatelessWidget {
  final Widget child;
  final String label;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const AccessibleRadio({
    super.key,
    required this.child,
    required this.label,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.accessibleRadio(
      label: label,
      value: value,
      onChanged: onChanged,
      child: child,
    );
  }
}

/// Accessible slider widget
class AccessibleSlider extends StatelessWidget {
  final Widget child;
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double>? onChanged;

  const AccessibleSlider({
    super.key,
    required this.child,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.accessibleSlider(
      label: label,
      value: value,
      min: min,
      max: max,
      onChanged: onChanged,
      child: child,
    );
  }
}

/// Accessible progress indicator widget
class AccessibleProgressIndicator extends StatelessWidget {
  final Widget child;
  final String label;
  final double? value;

  const AccessibleProgressIndicator({
    super.key,
    required this.child,
    required this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.accessibleProgressIndicator(
      label: label,
      value: value,
      child: child,
    );
  }
}

/// Accessible tab widget
class AccessibleTab extends StatelessWidget {
  final Widget child;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const AccessibleTab({
    super.key,
    required this.child,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.accessibleTab(
      label: label,
      selected: selected,
      onTap: onTap,
      child: child,
    );
  }
}

/// Accessibility wrapper extension for easy use
extension AccessibilityExtension on Widget {
  /// Wrap widget with accessibility features
  Widget withAccessibility({
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? link,
    bool? header,
    bool? textField,
    bool? image,
    bool? checked,
    bool? selected,
    bool? obscured,
    bool? enabled,
    bool? inMutallyExclusiveGroup,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return AccessibilityWrapper(
      label: label,
      hint: hint,
      value: value,
      button: button,
      link: link,
      header: header,
      textField: textField,
      image: image,
      checked: checked,
      selected: selected,
      obscured: obscured,
      enabled: enabled,
      inMutuallyExclusiveGroup: inMutallyExclusiveGroup,
      onTap: onTap,
      onLongPress: onLongPress,
      child: this,
    );
  }
}
