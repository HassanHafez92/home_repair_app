// File: lib/screens/customer/service_details_screen.dart
// Purpose: Detailed view of a service with booking option.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import 'package:home_repair_app/models/price_estimate_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/price_calculator_widget.dart';
import '../../theme/design_tokens.dart';
import '../../theme/page_transitions.dart';
import 'booking/booking_flow_screen.dart';
import '../../widgets/wrappers.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final ServiceEntity service;

  const ServiceDetailsScreen({super.key, required this.service});

  bool get _hasNetworkImage {
    final url = service.iconUrl.toLowerCase();
    return url.contains('unsplash') ||
        url.contains('pexels') ||
        url.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Create price estimate from service data
    final priceEstimate = PriceEstimateModel.estimate(
      minPrice: service.minPrice,
      maxPrice: service.maxPrice,
      inspectionFee: service.visitFee,
    );

    return PerformanceMonitorWrapper(
      screenName: 'ServiceDetailsScreen',
      child: Scaffold(
        body: Stack(
          children: [
            // Scrollable content
            CustomScrollView(
              slivers: [
                // Hero Image App Bar
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  stretch: true,
                  backgroundColor: colorScheme.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      service.name,
                      style: TextStyle(
                        fontWeight: DesignTokens.fontWeightBold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_hasNetworkImage)
                          CachedNetworkImage(
                            imageUrl: service.iconUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, a) => Container(
                              color: colorScheme.primaryContainer,
                              child: Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 60,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            errorWidget: (_, a, b) =>
                                _buildPlaceholderHero(colorScheme),
                          )
                        else
                          _buildPlaceholderHero(colorScheme),
                        // Gradient overlay for text readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(DesignTokens.spaceLG),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price & Rating Row
                        Container(
                          padding: const EdgeInsets.all(DesignTokens.spaceMD),
                          decoration: BoxDecoration(
                            color: DesignTokens.surfaceTint1,
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusLG,
                            ),
                            border: Border.all(color: DesignTokens.neutral200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'priceRange'.tr(),
                                      style: TextStyle(
                                        fontSize: DesignTokens.fontSizeSM,
                                        color: DesignTokens.neutral500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${service.minPrice.toInt()} - ${service.maxPrice.toInt()} EGP',
                                      style: TextStyle(
                                        fontSize: DesignTokens.fontSizeXL,
                                        fontWeight: DesignTokens.fontWeightBold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DesignTokens.spaceMD,
                                  vertical: DesignTokens.spaceXS,
                                ),
                                decoration: BoxDecoration(
                                  color: DesignTokens.accentOrange.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    DesignTokens.radiusFull,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: DesignTokens.accentOrange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '4.8',
                                      style: TextStyle(
                                        fontWeight: DesignTokens.fontWeightBold,
                                        color: DesignTokens.neutral800,
                                      ),
                                    ),
                                    Text(
                                      ' (120)',
                                      style: TextStyle(
                                        color: DesignTokens.neutral500,
                                        fontSize: DesignTokens.fontSizeSM,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spaceXS),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: DesignTokens.spaceMD,
                          ),
                          child: Text(
                            'visitFee'.tr(
                              args: [service.visitFee.toInt().toString()],
                            ),
                            style: TextStyle(
                              color: DesignTokens.neutral500,
                              fontSize: DesignTokens.fontSizeSM,
                            ),
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spaceLG),

                        // Description Section
                        _SectionHeader(title: 'description'.tr()),
                        const SizedBox(height: DesignTokens.spaceSM),
                        Text(
                          service.description,
                          style: TextStyle(
                            fontSize: DesignTokens.fontSizeBase,
                            height: 1.6,
                            color: DesignTokens.neutral700,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.spaceLG),

                        // What's Included Section
                        _SectionHeader(title: 'whatsIncluded'.tr()),
                        const SizedBox(height: DesignTokens.spaceSM),
                        _FeatureChip(
                          text: 'professionalService'.tr(),
                          icon: Icons.verified_user_outlined,
                        ),
                        _FeatureChip(
                          text: 'verifiedTechnician'.tr(),
                          icon: Icons.badge_outlined,
                        ),
                        _FeatureChip(
                          text: 'warranty30Days'.tr(),
                          icon: Icons.security_outlined,
                        ),

                        const SizedBox(height: DesignTokens.spaceLG),

                        // Price Estimate Calculator
                        PriceCalculatorWidget(
                          estimate: priceEstimate,
                          showAddOnSelection: false,
                          compact: false,
                        ),

                        // Bottom padding for sticky button
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Sticky Bottom CTA
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: DesignTokens.spaceLG,
                  right: DesignTokens.spaceLG,
                  top: DesignTokens.spaceMD,
                  bottom:
                      MediaQuery.of(context).padding.bottom +
                      DesignTokens.spaceMD,
                ),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Price summary
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'startingFrom'.tr(),
                            style: TextStyle(
                              fontSize: DesignTokens.fontSizeSM,
                              color: DesignTokens.neutral500,
                            ),
                          ),
                          Text(
                            '${service.minPrice.toInt()} EGP',
                            style: TextStyle(
                              fontSize: DesignTokens.fontSizeXL,
                              fontWeight: DesignTokens.fontWeightBold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Book button
                    Expanded(
                      child: CustomButton(
                        text: 'bookNow'.tr(),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            SlideUpPageRoute(
                              page: BookingFlowScreen(service: service),
                            ),
                          );
                        },
                      ),
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

  Widget _buildPlaceholderHero(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(gradient: DesignTokens.primaryGradient),
      child: Center(
        child: Icon(
          Icons.home_repair_service_rounded,
          size: 80,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: DesignTokens.fontSizeLG,
        fontWeight: DesignTokens.fontWeightBold,
        color: DesignTokens.neutral900,
      ),
    );
  }
}

/// Feature chip with icon
class _FeatureChip extends StatelessWidget {
  final String text;
  final IconData icon;

  const _FeatureChip({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.spaceSM),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: DesignTokens.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
            ),
            child: Icon(icon, color: DesignTokens.success, size: 18),
          ),
          const SizedBox(width: DesignTokens.spaceSM),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: DesignTokens.fontSizeBase,
                color: DesignTokens.neutral700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
