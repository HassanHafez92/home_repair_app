import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import '../theme/design_tokens.dart';

/// A horizontal scrolling section showing popular/trending services
class PopularServicesSection extends StatelessWidget {
  final List<ServiceEntity> services;
  final Function(ServiceEntity)? onServiceTap;

  const PopularServicesSection({
    super.key,
    required this.services,
    this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLG),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DesignTokens.spaceXS),
                decoration: BoxDecoration(
                  color: DesignTokens.accentOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: DesignTokens.accentOrange,
                  size: 18,
                ),
              ),
              const SizedBox(width: DesignTokens.spaceXS),
              Text(
                'mostPopularThisWeek'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: DesignTokens.fontWeightBold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),

        // Horizontal scrolling chips
        SizedBox(
          height: 44,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceMD,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Padding(
                padding: const EdgeInsets.only(right: DesignTokens.spaceSM),
                child: _PopularServiceChip(
                  service: service,
                  onTap: () => onServiceTap?.call(service),
                  colorScheme: colorScheme,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PopularServiceChip extends StatelessWidget {
  final ServiceEntity service;
  final VoidCallback? onTap;
  final ColorScheme colorScheme;

  const _PopularServiceChip({
    required this.service,
    this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceMD,
            vertical: DesignTokens.spaceXS,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: DesignTokens.spaceXS),
              Text(
                service.name.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: DesignTokens.fontWeightMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
