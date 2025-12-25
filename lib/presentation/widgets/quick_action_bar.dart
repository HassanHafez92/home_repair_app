import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/design_tokens.dart';

/// Enum representing the booking urgency type
enum BookingUrgency { emergency, scheduled }

/// Quick action bar with Emergency and Schedule toggle buttons
/// Allows users to indicate booking urgency before selecting a service
class QuickActionBar extends StatefulWidget {
  final ValueChanged<BookingUrgency>? onUrgencyChanged;
  final BookingUrgency initialUrgency;

  const QuickActionBar({
    super.key,
    this.onUrgencyChanged,
    this.initialUrgency = BookingUrgency.scheduled,
  });

  @override
  State<QuickActionBar> createState() => _QuickActionBarState();
}

class _QuickActionBarState extends State<QuickActionBar> {
  late BookingUrgency _selectedUrgency;

  @override
  void initState() {
    super.initState();
    _selectedUrgency = widget.initialUrgency;
  }

  void _selectUrgency(BookingUrgency urgency) {
    if (urgency != _selectedUrgency) {
      setState(() {
        _selectedUrgency = urgency;
      });
      widget.onUrgencyChanged?.call(urgency);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceXS),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
      ),
      child: Row(
        children: [
          // Emergency Button
          Expanded(
            child: _ActionButton(
              icon: Icons.flash_on_rounded,
              label: 'emergencyService'.tr(),
              isSelected: _selectedUrgency == BookingUrgency.emergency,
              selectedColor: DesignTokens.accentRed,
              onTap: () => _selectUrgency(BookingUrgency.emergency),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceXS),
          // Schedule Button
          Expanded(
            child: _ActionButton(
              icon: Icons.calendar_month_rounded,
              label: 'scheduleLater'.tr(),
              isSelected: _selectedUrgency == BookingUrgency.scheduled,
              selectedColor: colorScheme.primary,
              onTap: () => _selectUrgency(BookingUrgency.scheduled),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
        child: AnimatedContainer(
          duration: DesignTokens.durationFast,
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceSM,
            vertical: DesignTokens.spaceSM,
          ),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
            border: isSelected
                ? null
                : Border.all(color: DesignTokens.neutral300, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : DesignTokens.neutral600,
              ),
              const SizedBox(width: DesignTokens.spaceXS),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: DesignTokens.fontWeightMedium,
                    color: isSelected ? Colors.white : DesignTokens.neutral600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
