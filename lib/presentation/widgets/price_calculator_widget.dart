// File: lib/presentation/widgets/price_calculator_widget.dart
// Purpose: Interactive price calculator showing breakdown with inspection fee model.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/models/price_estimate_model.dart';
import 'package:home_repair_app/models/service_addon_model.dart';

/// Widget displaying price estimate with inspection fee breakdown
class PriceCalculatorWidget extends StatelessWidget {
  /// The price estimate to display
  final PriceEstimateModel estimate;

  /// Available add-ons for the service
  final List<ServiceAddOnModel> availableAddOns;

  /// Callback when an add-on is toggled
  final Function(ServiceAddOnModel addon, bool selected)? onAddOnToggled;

  /// Whether the widget is in compact mode (for booking confirmation)
  final bool compact;

  /// Whether to show the add-on selection (false in confirmation step)
  final bool showAddOnSelection;

  const PriceCalculatorWidget({
    super.key,
    required this.estimate,
    this.availableAddOns = const [],
    this.onAddOnToggled,
    this.compact = false,
    this.showAddOnSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: compact
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calculate_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'priceEstimate'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    estimate.priceRangeDisplay,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Inspection fee info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue.withValues(alpha: 0.1),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'inspectionFeeInfo'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add-ons section (if available and showing)
                if (showAddOnSelection && availableAddOns.isNotEmpty) ...[
                  Text(
                    'optionalAddOns'.tr(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...availableAddOns.map(
                    (addon) => _AddOnTile(
                      addon: addon,
                      onChanged: onAddOnToggled != null
                          ? (selected) => onAddOnToggled!(addon, selected)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                ],

                // Price breakdown
                _PriceRow(
                  label: 'estimatedServiceFee'.tr(),
                  value: estimate.basePrice > 0
                      ? estimate.basePrice
                      : (estimate.minPrice + estimate.maxPrice) / 2,
                  isEstimate: estimate.basePrice == 0,
                ),

                // Selected add-ons breakdown
                if (estimate.selectedAddOns.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ...estimate.selectedAddOns.map(
                    (addon) => _PriceRow(
                      label: addon.name,
                      value: addon.price,
                      isSubItem: true,
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                _PriceRow(
                  label: 'vat'.tr(),
                  value: estimate.vatAmount,
                  isSubItem: true,
                ),

                if (estimate.discountAmount != null &&
                    estimate.discountAmount! > 0) ...[
                  const SizedBox(height: 8),
                  _PriceRow(
                    label: 'discount'.tr(),
                    value: -estimate.discountAmount!,
                    isDiscount: true,
                  ),
                ],

                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),

                // Inspection fee deduction
                _PriceRow(
                  label: 'inspectionFeePaid'.tr(),
                  value: -estimate.inspectionFee,
                  isDeduction: true,
                  helperText: 'deductedFromTotal'.tr(),
                ),

                const SizedBox(height: 12),

                // Final amount due
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'amountDueAfterInspection'.tr(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${estimate.amountDueAfterInspection.toInt()} EGP',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer note
                if (!compact) ...[
                  const SizedBox(height: 12),
                  Text(
                    'priceEstimateNote'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual add-on tile with checkbox
class _AddOnTile extends StatelessWidget {
  final ServiceAddOnModel addon;
  final Function(bool)? onChanged;

  const _AddOnTile({required this.addon, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: addon.isSelected,
      onChanged: onChanged != null
          ? (value) => onChanged!(value ?? false)
          : null,
      title: Text(addon.name, style: const TextStyle(fontSize: 14)),
      subtitle: addon.description != null
          ? Text(
              addon.description!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            )
          : null,
      secondary: Text(
        '+${addon.price.toInt()} EGP',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

/// Individual price row in the breakdown
class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isEstimate;
  final bool isSubItem;
  final bool isDiscount;
  final bool isDeduction;
  final String? helperText;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isEstimate = false,
    this.isSubItem = false,
    this.isDiscount = false,
    this.isDeduction = false,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color? valueColor;
    if (isDiscount || isDeduction) {
      valueColor = Colors.green[700];
    }

    return Padding(
      padding: EdgeInsets.only(left: isSubItem ? 16 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSubItem ? Colors.grey[600] : null,
                        fontSize: isSubItem ? 13 : 14,
                      ),
                    ),
                    if (isEstimate) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'estimate'.tr(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '${value >= 0 ? '' : '-'}${value.abs().toInt()} EGP',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSubItem ? FontWeight.normal : FontWeight.w600,
                  color: valueColor,
                  fontSize: isSubItem ? 13 : 14,
                ),
              ),
            ],
          ),
          if (helperText != null) ...[
            const SizedBox(height: 2),
            Text(
              helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
