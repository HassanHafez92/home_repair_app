// File: lib/presentation/widgets/emergency_priority_selector.dart
// Purpose: Widget for selecting service priority level during booking.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/models/emergency_service_model.dart';

/// Widget for selecting service priority during booking
class EmergencyPrioritySelector extends StatelessWidget {
  /// Current selected priority
  final ServicePriority selectedPriority;

  /// Base service price for calculation
  final double basePrice;

  /// Callback when priority changes
  final Function(ServicePriority, EmergencyServiceModel) onPriorityChanged;

  const EmergencyPrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.basePrice,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(Icons.speed, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'selectPriority'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'priorityDescription'.tr(),
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // Priority options
        ...ServicePriority.values.map((priority) {
          final model = EmergencyServiceModel.withPriority(
            priority: priority,
            basePrice: basePrice,
          );
          return _PriorityOptionCard(
            priority: priority,
            model: model,
            isSelected: selectedPriority == priority,
            onTap: () => onPriorityChanged(priority, model),
          );
        }),
      ],
    );
  }
}

class _PriorityOptionCard extends StatelessWidget {
  final ServicePriority priority;
  final EmergencyServiceModel model;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityOptionCard({
    required this.priority,
    required this.model,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cardColor = _getCardColor();
    final iconData = _getIcon();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? cardColor.withValues(alpha: 0.15)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cardColor : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: cardColor, size: 24),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _getPriorityTitle(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (model.isEmergency) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '24/7',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${'responseTime'.tr()}: ${model.responseTimeDisplay}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${model.totalPrice.toInt()} EGP',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
                if (model.additionalCost > 0)
                  Text(
                    '+${model.additionalCost.toInt()} EGP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),

            // Selection indicator
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? colorScheme.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCardColor() {
    switch (priority) {
      case ServicePriority.normal:
        return Colors.grey;
      case ServicePriority.sameDay:
        return Colors.blue;
      case ServicePriority.urgent:
        return Colors.orange;
      case ServicePriority.emergency:
        return Colors.red;
    }
  }

  IconData _getIcon() {
    switch (priority) {
      case ServicePriority.normal:
        return Icons.schedule;
      case ServicePriority.sameDay:
        return Icons.today;
      case ServicePriority.urgent:
        return Icons.priority_high;
      case ServicePriority.emergency:
        return Icons.emergency;
    }
  }

  String _getPriorityTitle() {
    switch (priority) {
      case ServicePriority.normal:
        return 'normalPriority'.tr();
      case ServicePriority.sameDay:
        return 'sameDayPriority'.tr();
      case ServicePriority.urgent:
        return 'urgentPriority'.tr();
      case ServicePriority.emergency:
        return 'emergencyPriority'.tr();
    }
  }
}

/// Emergency type selection bottom sheet
class EmergencyTypeSheet extends StatelessWidget {
  final Function(String) onTypeSelected;

  const EmergencyTypeSheet({super.key, required this.onTypeSelected});

  static Future<String?> show(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EmergencyTypeSheet(
        onTypeSelected: (type) => Navigator.pop(context, type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'selectEmergencyType'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Divider(height: 1),

          // Options
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: EmergencyTypes.all.length,
              itemBuilder: (context, index) {
                final type = EmergencyTypes.all[index];
                return ListTile(
                  leading: Icon(_getEmergencyIcon(type), color: Colors.red),
                  title: Text(type),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => onTypeSelected(type),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getEmergencyIcon(String type) {
    if (type.toLowerCase().contains('water') ||
        type.toLowerCase().contains('pipe')) {
      return Icons.water_damage;
    } else if (type.toLowerCase().contains('power') ||
        type.toLowerCase().contains('electric')) {
      return Icons.power_off;
    } else if (type.toLowerCase().contains('gas')) {
      return Icons.local_fire_department;
    } else if (type.toLowerCase().contains('lock')) {
      return Icons.lock;
    } else if (type.toLowerCase().contains('ac')) {
      return Icons.ac_unit;
    } else if (type.toLowerCase().contains('heat')) {
      return Icons.thermostat;
    } else if (type.toLowerCase().contains('security')) {
      return Icons.security;
    }
    return Icons.emergency;
  }
}
