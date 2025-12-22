import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/design_tokens.dart';

class PromotionalBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const PromotionalBanner({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        gradient: LinearGradient(
          colors: [colorScheme.primary, DesignTokens.primaryBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: DesignTokens.shadowMedium,
      ),
      child: Stack(
        children: [
          // Background decorative elements
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceLG),
            child: Row(
              children: [
                // Text Content
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spaceSM,
                          vertical: DesignTokens.spaceXXS,
                        ),
                        decoration: BoxDecoration(
                          color: DesignTokens.accentOrange,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusXS,
                          ),
                        ),
                        child: Text(
                          'promoDiscount'.tr().toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: DesignTokens.fontWeightBold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceSM),
                      Text(
                        'promoActivateApartment'.tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: DesignTokens.fontWeightBold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceXS),
                      Text(
                        'promoColorChoice'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: DesignTokens.spaceLG),
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusSM,
                            ),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.spaceLG,
                          ),
                          textStyle: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: DesignTokens.fontWeightBold,
                          ),
                        ),
                        child: Text('viewDetails'.tr()),
                      ),
                    ],
                  ),
                ),
                // Icon
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.format_paint_rounded,
                      size: 90,
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
