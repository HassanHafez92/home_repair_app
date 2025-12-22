import 'package:flutter/material.dart';
import 'package:home_repair_app/domain/entities/order_entity.dart';
import 'package:home_repair_app/domain/entities/technician_entity.dart';
import '../theme/design_tokens.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.isSmall = false,
  });

  // Factory constructor for OrderStatus
  factory StatusBadge.fromOrderStatus(
    OrderStatus status, {
    bool isSmall = false,
  }) {
    return StatusBadge(
      text: status.name.toUpperCase(),
      color: DesignTokens.getStatusColor(status.name),
      isSmall: isSmall,
    );
  }

  // Factory constructor for TechnicianStatus
  factory StatusBadge.fromTechnicianStatus(
    TechnicianStatus status, {
    bool isSmall = false,
  }) {
    return StatusBadge(
      text: status.name.toUpperCase(),
      color: DesignTokens.getStatusColor(status.name),
      isSmall: isSmall,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? DesignTokens.spaceXS : DesignTokens.spaceSM,
        vertical: isSmall ? DesignTokens.spaceXXS : DesignTokens.spaceXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontSize: isSmall ? 10 : 11,
          fontWeight: DesignTokens.fontWeightBold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
