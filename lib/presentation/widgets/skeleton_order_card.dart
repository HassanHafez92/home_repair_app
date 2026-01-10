import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'skeleton_loader.dart';

/// Skeleton loader for order cards to show during loading state
class SkeletonOrderCard extends StatelessWidget {
  const SkeletonOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? DesignTokens.neutral800
        : DesignTokens.neutral200;

    return ShimmerEffect(
      child: Container(
        margin: const EdgeInsets.only(bottom: DesignTokens.spaceMD),
        padding: const EdgeInsets.all(DesignTokens.spaceMD),
        decoration: BoxDecoration(
          color: isDark ? DesignTokens.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
          boxShadow: DesignTokens.shadowSoft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service title and badge row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service name placeholder
                      Container(
                        width: 140,
                        height: 18,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusXS,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Payment badge placeholder
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                // Button placeholder
                Container(
                  width: 80,
                  height: 36,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSM),
                  ),
                ),
              ],
            ),

            const SizedBox(height: DesignTokens.spaceMD),

            // Divider
            Container(height: 1, color: baseColor),

            const SizedBox(height: DesignTokens.spaceMD),

            // Date and Service Officer row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 12,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusXS,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 90,
                        height: 14,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusXS,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusXS,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusXS,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A list of skeleton order cards for loading states
class SkeletonOrderList extends StatelessWidget {
  final int itemCount;

  const SkeletonOrderList({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceMD),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => const SkeletonOrderCard(),
        ),
      ),
    );
  }
}
