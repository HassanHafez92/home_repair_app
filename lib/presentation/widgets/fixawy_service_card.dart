import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import '../theme/design_tokens.dart';
import 'optimized_network_image.dart';

/// Fixawy-style service card with 60/40 image-to-text ratio
///
/// Design based on Fixawy website analysis:
/// - Top 60%: Full-bleed cover image
/// - Bottom 40%: Title and description with padding
/// - 15px rounded corners with soft shadow
/// - Semantic accessibility labels
class FixawyServiceCard extends StatelessWidget {
  final ServiceEntity service;
  final VoidCallback onTap;
  final bool showPrice;
  final bool showDescription;

  const FixawyServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.showPrice = true,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: _buildAccessibilityLabel(),
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image section (60%)
                  Expanded(
                    flex: 6,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Service image
                        OptimizedNetworkImage(
                          imageUrl: service.iconUrl,
                          fit: BoxFit.cover,
                        ),
                        // Price badge (top right)
                        if (showPrice)
                          Positioned(
                            top: DesignTokens.spaceXS,
                            right: DesignTokens.spaceXS,
                            child: _buildPriceBadge(context),
                          ),
                      ],
                    ),
                  ),
                  // Text section (40%)
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Title
                          Text(
                            service.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: DesignTokens.fontWeightBold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (showDescription) ...[
                            const SizedBox(height: 4),
                            // Description
                            Text(
                              service.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: DesignTokens.neutral500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceBadge(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceXS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.fixawyYellow,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'fromPrice'.tr(
          namedArgs: {'price': service.minPrice.toInt().toString()},
        ),
        style: TextStyle(
          fontSize: 10,
          fontWeight: DesignTokens.fontWeightBold,
          color: DesignTokens.fixawyNavy,
          fontFamily: theme.textTheme.bodySmall?.fontFamily,
        ),
      ),
    );
  }

  String _buildAccessibilityLabel() {
    final priceText = showPrice
        ? 'Starting from ${service.minPrice.toInt()} EGP. '
        : '';
    return '${service.name}. ${service.description}. '
        '$priceText'
        'Double tap to view details.';
  }
}

/// Compact variant of Fixawy service card for smaller grids
class FixawyServiceCardCompact extends StatelessWidget {
  final ServiceEntity service;
  final VoidCallback onTap;

  const FixawyServiceCardCompact({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: '${service.name}. Double tap to view details.',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
                boxShadow: DesignTokens.shadowSoft,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Image (square)
                  AspectRatio(
                    aspectRatio: 1,
                    child: OptimizedNetworkImage(
                      imageUrl: service.iconUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Title only
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      service.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: DesignTokens.fontWeightSemiBold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
