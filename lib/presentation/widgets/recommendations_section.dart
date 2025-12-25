// File: lib/presentation/widgets/recommendations_section.dart
// Purpose: Widget displaying personalized service recommendations on home screen.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/services/recommendation_service.dart';
import 'package:home_repair_app/presentation/screens/customer/recommendations_screen.dart';
import 'package:home_repair_app/presentation/theme/design_tokens.dart';

/// Widget displaying a section of recommended services
class RecommendationsSection extends StatelessWidget {
  /// List of recommendations to display
  final List<RecommendedService> recommendations;

  /// Callback when a service is tapped
  final Function(RecommendedService) onServiceTap;

  /// Section title
  final String? title;

  /// Whether to show the reason badge
  final bool showReasonBadge;

  /// Optional callback when "See All" is tapped
  final VoidCallback? onSeeAllTap;

  const RecommendationsSection({
    super.key,
    required this.recommendations,
    required this.onServiceTap,
    this.title,
    this.showReasonBadge = true,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceMD),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: DesignTokens.spaceXS),
              Text(
                title ?? 'recommendedForYou'.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  if (onSeeAllTap != null) {
                    onSeeAllTap!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecommendationsScreen(
                          initialRecommendations: recommendations,
                        ),
                      ),
                    );
                  }
                },
                child: Text('seeAll'.tr()),
              ),
            ],
          ),
        ),

        const SizedBox(height: DesignTokens.spaceSM),

        // Horizontal scroll list
        SizedBox(
          height: 210, // Slightly taller to accommodate shadow
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceMD,
            ),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final rec = recommendations[index];
              return _RecommendationCard(
                recommendation: rec,
                onTap: () => onServiceTap(rec),
                showReasonBadge: showReasonBadge,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Card widget for a single recommendation
class _RecommendationCard extends StatelessWidget {
  final RecommendedService recommendation;
  final VoidCallback onTap;
  final bool showReasonBadge;

  const _RecommendationCard({
    required this.recommendation,
    required this.onTap,
    required this.showReasonBadge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = recommendation.service;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(
          right: DesignTokens.spaceMD,
          bottom: DesignTokens.spaceXS,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          boxShadow: DesignTokens.shadowSoft,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Icon area
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DesignTokens.radiusMD),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getServiceIcon(service.category),
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  // Reason badge
                  if (showReasonBadge)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getReasonColor(recommendation.reason, theme),
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusSM,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          _getReasonLabel(recommendation.reason),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceSM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${service.minPrice.toInt()} EGP',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (service.maxPrice > service.minPrice)
                          Text(
                            ' - ${service.maxPrice.toInt()} EGP',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getServiceIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('plumb') || cat.contains('سباكة')) {
      return Icons.plumbing;
    } else if (cat.contains('electric') || cat.contains('كهرباء')) {
      return Icons.electrical_services;
    } else if (cat.contains('ac') || cat.contains('مكيف')) {
      return Icons.ac_unit;
    } else if (cat.contains('paint') || cat.contains('دهان')) {
      return Icons.format_paint;
    } else if (cat.contains('clean') || cat.contains('نظافة')) {
      return Icons.cleaning_services;
    }
    return Icons.build;
  }

  Color _getReasonColor(RecommendationReason reason, ThemeData theme) {
    switch (reason) {
      case RecommendationReason.categoryInterest:
        return Colors.purple.shade400;
      case RecommendationReason.customersAlsoBooked:
        return Colors.orange.shade400;
      case RecommendationReason.seasonal:
        return Colors.green.shade500;
      case RecommendationReason.popular:
        return Colors.blue.shade400;
      case RecommendationReason.recentlyViewed:
        return Colors.grey.shade600;
    }
  }

  String _getReasonLabel(RecommendationReason reason) {
    switch (reason) {
      case RecommendationReason.categoryInterest:
        return 'forYou'.tr();
      case RecommendationReason.customersAlsoBooked:
        return 'alsoBooked'.tr();
      case RecommendationReason.seasonal:
        return 'seasonal'.tr();
      case RecommendationReason.popular:
        return 'popular'.tr();
      case RecommendationReason.recentlyViewed:
        return 'viewed'.tr();
    }
  }
}

/// Widget for "Customers Also Booked" section
class CustomersAlsoBookedSection extends StatelessWidget {
  final List<RecommendedService> recommendations;
  final Function(RecommendedService) onServiceTap;

  const CustomersAlsoBookedSection({
    super.key,
    required this.recommendations,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    // Filter only "customers also booked" recommendations
    final alsoBooked = recommendations
        .where((r) => r.reason == RecommendationReason.customersAlsoBooked)
        .toList();

    if (alsoBooked.isEmpty) {
      return const SizedBox.shrink();
    }

    return RecommendationsSection(
      title: 'customersAlsoBooked'.tr(),
      recommendations: alsoBooked,
      onServiceTap: onServiceTap,
      showReasonBadge: false,
    );
  }
}
