import 'package:flutter/material.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import '../theme/design_tokens.dart';

class ServiceCard extends StatelessWidget {
  final ServiceEntity service;
  final VoidCallback onTap;
  final IconData? iconData;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Book ${service.name} service',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: DesignTokens.shadowSoft,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceSM,
              vertical: DesignTokens.spaceBase,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceMD),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData ?? Icons.build_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: DesignTokens.iconSizeLG,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceMD),
                // Text
                Text(
                  service.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: DesignTokens.fontWeightBold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
