import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// A shimmer effect widget for skeleton loading states
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        widget.baseColor ??
        (isDark ? DesignTokens.neutral800 : DesignTokens.neutral200);
    final highlightColor =
        widget.highlightColor ??
        (isDark ? DesignTokens.neutral700 : DesignTokens.neutral100);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

/// Skeleton placeholder for a card
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.width,
    this.height = 120,
    this.borderRadius = DesignTokens.radiusLG,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? DesignTokens.neutral800 : DesignTokens.neutral200,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton placeholder for a service card in a grid
class SkeletonServiceCard extends StatelessWidget {
  const SkeletonServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? DesignTokens.neutral800
        : DesignTokens.neutral200;

    return ShimmerEffect(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? DesignTokens.surfaceDark : DesignTokens.surfaceLight,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
          border: Border.all(
            color: isDark ? DesignTokens.neutral700 : DesignTokens.neutral200,
          ),
        ),
        padding: const EdgeInsets.all(DesignTokens.spaceSM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceXS),
            // Price badge placeholder
            Container(
              width: 50,
              height: 16,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceXXS),
            // Title placeholder
            Container(
              width: 70,
              height: 14,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton placeholder for text lines
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonText({
    super.key,
    this.width = double.infinity,
    this.height = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerEffect(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? DesignTokens.neutral800 : DesignTokens.neutral200,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
        ),
      ),
    );
  }
}

/// Skeleton placeholder for a list item
class SkeletonListItem extends StatelessWidget {
  const SkeletonListItem({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? DesignTokens.neutral800
        : DesignTokens.neutral200;

    return ShimmerEffect(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceSM),
        child: Row(
          children: [
            // Avatar placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceMD),
            // Text lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusXS,
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceXS),
                  Container(
                    width: 120,
                    height: 12,
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
      ),
    );
  }
}

/// A grid of skeleton service cards for loading states
class SkeletonServiceGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;

  const SkeletonServiceGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: DesignTokens.spaceMD,
        mainAxisSpacing: DesignTokens.spaceMD,
        childAspectRatio: 0.85,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonServiceCard(),
    );
  }
}

/// A list of skeleton items for loading states
class SkeletonList extends StatelessWidget {
  final int itemCount;

  const SkeletonList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) => const SkeletonListItem()),
    );
  }
}
