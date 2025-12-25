// File: lib/presentation/screens/customer/recommendations_screen.dart
// Purpose: Full screen displaying all personalized service recommendations.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/services/recommendation_service.dart';
import 'package:home_repair_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:home_repair_app/presentation/blocs/auth/auth_state.dart';
import 'package:home_repair_app/presentation/blocs/service/service_bloc.dart';
import 'package:home_repair_app/presentation/theme/design_tokens.dart';
import 'service_details_screen.dart';

/// Screen displaying all personalized recommendations for the user
class RecommendationsScreen extends StatefulWidget {
  /// Optional initial recommendations to display
  final List<RecommendedService>? initialRecommendations;

  const RecommendationsScreen({super.key, this.initialRecommendations});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  late Future<List<RecommendedService>> _recommendationsFuture;
  final RecommendationService _recommendationService = RecommendationService();

  @override
  void initState() {
    super.initState();
    if (widget.initialRecommendations != null) {
      _recommendationsFuture = Future.value(widget.initialRecommendations);
    } else {
      _loadRecommendations();
    }
  }

  void _loadRecommendations() {
    final authState = context.read<AuthBloc>().state;
    final serviceState = context.read<ServiceBloc>().state;

    if (authState is AuthAuthenticated && serviceState.services.isNotEmpty) {
      _recommendationsFuture = _recommendationService.getRecommendations(
        userId: authState.userId,
        allServices: serviceState.services,
        limit: 20, // Load more recommendations for full page
      );
    } else {
      _recommendationsFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('recommendedForYou'.tr()), elevation: 0),
      body: FutureBuilder<List<RecommendedService>>(
        future: _recommendationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: DesignTokens.spaceMD),
                  Text(
                    'errorLoadingRecommendations'.tr(),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: DesignTokens.spaceMD),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadRecommendations();
                      });
                    },
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          final recommendations = snapshot.data ?? [];

          if (recommendations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 64,
                    color: DesignTokens.neutral400,
                  ),
                  const SizedBox(height: DesignTokens.spaceMD),
                  Text(
                    'noRecommendationsYet'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: DesignTokens.neutral600,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceSM),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'browseServicesToGetRecommendations'.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: DesignTokens.neutral500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Group recommendations by reason
          final groupedRecommendations = _groupByReason(recommendations);

          return ListView.builder(
            padding: const EdgeInsets.all(DesignTokens.spaceMD),
            itemCount: groupedRecommendations.length,
            itemBuilder: (context, index) {
              final entry = groupedRecommendations.entries.elementAt(index);
              final reason = entry.key;
              final items = entry.value;

              return _RecommendationGroup(
                reason: reason,
                recommendations: items,
                onServiceTap: (rec) => _navigateToServiceDetails(rec),
              );
            },
          );
        },
      ),
    );
  }

  Map<RecommendationReason, List<RecommendedService>> _groupByReason(
    List<RecommendedService> recommendations,
  ) {
    final grouped = <RecommendationReason, List<RecommendedService>>{};
    for (final rec in recommendations) {
      grouped.putIfAbsent(rec.reason, () => []).add(rec);
    }
    return grouped;
  }

  void _navigateToServiceDetails(RecommendedService recommendation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsScreen(service: recommendation.service),
      ),
    );
  }
}

/// Widget for a group of recommendations by reason
class _RecommendationGroup extends StatelessWidget {
  final RecommendationReason reason;
  final List<RecommendedService> recommendations;
  final Function(RecommendedService) onServiceTap;

  const _RecommendationGroup({
    required this.reason,
    required this.recommendations,
    required this.onServiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceMD),
          child: Row(
            children: [
              Icon(
                _getReasonIcon(reason),
                size: 20,
                color: _getReasonColor(reason),
              ),
              const SizedBox(width: 8),
              Text(
                _getReasonTitle(reason),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Grid of recommendations
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: DesignTokens.spaceMD,
            mainAxisSpacing: DesignTokens.spaceMD,
            childAspectRatio: 0.85,
          ),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            final rec = recommendations[index];
            return _RecommendationTile(
              recommendation: rec,
              onTap: () => onServiceTap(rec),
            );
          },
        ),

        const SizedBox(height: DesignTokens.spaceLG),
      ],
    );
  }

  IconData _getReasonIcon(RecommendationReason reason) {
    switch (reason) {
      case RecommendationReason.categoryInterest:
        return Icons.favorite;
      case RecommendationReason.customersAlsoBooked:
        return Icons.group;
      case RecommendationReason.seasonal:
        return Icons.wb_sunny;
      case RecommendationReason.popular:
        return Icons.trending_up;
      case RecommendationReason.recentlyViewed:
        return Icons.history;
    }
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

  String _getReasonTitle(RecommendationReason reason) {
    switch (reason) {
      case RecommendationReason.categoryInterest:
        return 'basedOnYourInterests'.tr();
      case RecommendationReason.customersAlsoBooked:
        return 'customersAlsoBooked'.tr();
      case RecommendationReason.seasonal:
        return 'popularThisSeason'.tr();
      case RecommendationReason.popular:
        return 'popularServices'.tr();
      case RecommendationReason.recentlyViewed:
        return 'recentlyViewed'.tr();
    }
  }
}

/// Tile widget for individual recommendation
class _RecommendationTile extends StatelessWidget {
  final RecommendedService recommendation;
  final VoidCallback onTap;

  const _RecommendationTile({
    required this.recommendation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final service = recommendation.service;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          boxShadow: DesignTokens.shadowSoft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service icon/image area
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(DesignTokens.radiusMD),
                ),
              ),
              child: Center(
                child: Icon(
                  _getServiceIcon(service.category),
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.spaceSM),
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
                        if (service.maxPrice > service.minPrice) ...[
                          Text(
                            ' - ${service.maxPrice.toInt()} EGP',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: DesignTokens.neutral500,
                            ),
                          ),
                        ],
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
}
