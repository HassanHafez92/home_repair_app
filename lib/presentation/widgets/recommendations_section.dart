// File: lib/presentation/widgets/recommendations_section.dart
// Purpose: Widget displaying personalized service recommendations on home screen.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/services/recommendation_service.dart';
import 'package:home_repair_app/presentation/screens/customer/recommendations_screen.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
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

        const SizedBox(height: 8),

        // Horizontal scroll list
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Icon area
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
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
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getReasonColor(recommendation.reason),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getReasonLabel(recommendation.reason),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          '${service.minPrice.toInt()} EGP',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ' - ${service.maxPrice.toInt()} EGP',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
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

  Color _getReasonColor(RecommendationReason reason) {
    switch (reason) {
      case RecommendationReason.categoryInterest:
        return Colors.purple;
      case RecommendationReason.customersAlsoBooked:
        return Colors.orange;
      case RecommendationReason.seasonal:
        return Colors.green;
      case RecommendationReason.popular:
        return Colors.blue;
      case RecommendationReason.recentlyViewed:
        return Colors.grey;
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
