import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// A breadcrumb item representing a navigation step
class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbItem({required this.label, this.onTap});
}

/// Breadcrumb navigation widget for hierarchical navigation
///
/// Displays a horizontal list of navigation items separated by chevron icons.
/// The last item is styled as the current page (non-clickable).
/// Supports RTL layouts automatically.
class BreadcrumbNavigator extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Color? activeColor;
  final Color? inactiveColor;

  const BreadcrumbNavigator({
    super.key,
    required this.items,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Semantics(
      label: 'Breadcrumb navigation',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Breadcrumb item
                Semantics(
                  button: !isLast,
                  label: isLast
                      ? 'Current page: ${item.label}'
                      : 'Navigate to ${item.label}',
                  child: TextButton(
                    onPressed: isLast ? null : item.onTap,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceXS,
                        vertical: DesignTokens.spaceXXS,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: isLast
                            ? (inactiveColor ?? DesignTokens.neutral600)
                            : (activeColor ?? colorScheme.primary),
                        fontWeight: isLast
                            ? DesignTokens.fontWeightSemiBold
                            : DesignTokens.fontWeightRegular,
                        fontSize: DesignTokens.fontSizeSM,
                      ),
                    ),
                  ),
                ),
                // Separator
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceXXS,
                    ),
                    child: Icon(
                      // Flip chevron for RTL
                      isRtl ? Icons.chevron_left : Icons.chevron_right,
                      size: 16,
                      color: DesignTokens.neutral400,
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
