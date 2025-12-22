import 'package:flutter/material.dart';
import 'package:home_repair_app/domain/entities/technician_entity.dart';
import 'status_badge.dart';
import 'rating_stars.dart';
import '../theme/design_tokens.dart';

class TechnicianCard extends StatelessWidget {
  final TechnicianEntity technician;
  final VoidCallback? onTap;
  final bool showStatus;

  const TechnicianCard({
    super.key,
    required this.technician,
    this.onTap,
    this.showStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spaceMD),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceMD),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                ),
                alignment: Alignment.center,
                child: Text(
                  technician.fullName[0].toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: DesignTokens.fontWeightBold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      technician.fullName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: DesignTokens.fontWeightBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RatingStars(rating: technician.rating, size: 14),
                    const SizedBox(height: 4),
                    Text(
                      technician.specializations.join(', '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: DesignTokens.neutral500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (showStatus)
                Padding(
                  padding: const EdgeInsets.only(left: DesignTokens.spaceSM),
                  child: StatusBadge.fromTechnicianStatus(
                    technician.status,
                    isSmall: true,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
