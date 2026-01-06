// File: lib/presentation/screens/customer/promo_landing_screen.dart
// Purpose: Landing screen for promotional deep links

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:home_repair_app/presentation/theme/design_tokens.dart';

/// Landing screen for promotional deep links (e.g., /promo/SAVE20)
class PromoLandingScreen extends StatefulWidget {
  final String? promoCode;

  const PromoLandingScreen({super.key, this.promoCode});

  @override
  State<PromoLandingScreen> createState() => _PromoLandingScreenState();
}

class _PromoLandingScreenState extends State<PromoLandingScreen> {
  bool _isApplying = false;
  bool _isApplied = false;

  @override
  void initState() {
    super.initState();
    if (widget.promoCode != null && widget.promoCode!.isNotEmpty) {
      _applyPromoCode();
    }
  }

  Future<void> _applyPromoCode() async {
    setState(() => _isApplying = true);

    // Simulate promo code validation
    await Future.delayed(const Duration(seconds: 1));

    // In production, validate against backend
    setState(() {
      _isApplying = false;
      _isApplied = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primary, colorScheme.primaryContainer],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceLG),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Promo icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isApplied ? Icons.check_circle : Icons.local_offer,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: DesignTokens.spaceXL),

                // Title
                Text(
                  _isApplied ? 'Promo Applied!' : 'Special Offer',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: DesignTokens.fontWeightBold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: DesignTokens.spaceMD),

                // Promo code display
                if (widget.promoCode != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.spaceLG,
                      vertical: DesignTokens.spaceMD,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMD,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.promoCode!.toUpperCase(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: DesignTokens.fontWeightBold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spaceMD),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: widget.promoCode!),
                            );
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code copied!')),
                            );
                          },
                          icon: const Icon(Icons.copy, color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: DesignTokens.spaceMD),

                  Text(
                    _isApplied
                        ? 'Your discount will be applied at checkout'
                        : 'Get 20% off your first service',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: DesignTokens.space2XL),

                // Loading indicator or CTA button
                if (_isApplying)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.go('/customer/home'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          vertical: DesignTokens.spaceMD,
                        ),
                      ),
                      child: Text(
                        _isApplied ? 'Start Browsing' : 'Browse Services',
                        style: const TextStyle(
                          fontWeight: DesignTokens.fontWeightBold,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: DesignTokens.spaceMD),

                // Skip link
                TextButton(
                  onPressed: () => context.go('/customer/home'),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
