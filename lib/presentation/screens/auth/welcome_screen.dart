// File: lib/screens/auth/welcome_screen.dart
// Purpose: Welcome screen with House Maintenance style design.

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:home_repair_app/services/locale_provider.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'technician_signup_screen.dart';
import '../../theme/design_tokens.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: DesignTokens.headerGradient,
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Header with branding
                Padding(
                  padding: const EdgeInsets.all(DesignTokens.spaceLG),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.home_repair_service_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'House',
                            style: TextStyle(
                              fontSize: DesignTokens.fontSizeXL,
                              fontWeight: DesignTokens.fontWeightBold,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'maintenance',
                            style: TextStyle(
                              fontSize: DesignTokens.fontSizeSM,
                              fontWeight: DesignTokens.fontWeightLight,
                              color: Colors.white.withValues(alpha: 0.9),
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Hero Image
                Expanded(
                  flex: 3,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      _buildHeroSlide(
                        imagePath: 'assets/images/worker_hero.png',
                        title: 'welcomeMessage'.tr(),
                        subtitle: 'welcomeSubtitle'.tr(),
                      ),
                      _buildHeroSlide(
                        imagePath: 'assets/images/promo_banner.png',
                        title: 'professionalService'.tr(),
                        subtitle: 'trustedProfessionals'.tr(),
                      ),
                      _buildHeroSlide(
                        imagePath: 'assets/images/service_worker.png',
                        title: 'easyBooking'.tr(),
                        subtitle: 'bookInMinutes'.tr(),
                      ),
                    ],
                  ),
                ),

                // Bottom card with actions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(DesignTokens.spaceLG),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(DesignTokens.radius2XL),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? DesignTokens.primaryBlue
                                  : DesignTokens.neutral300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceLG),

                      // Next/Get Started button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < 2) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignTokens.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: DesignTokens.spaceMD,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                DesignTokens.radiusMD,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPage < 2 ? 'next'.tr() : 'getStarted'.tr(),
                            style: const TextStyle(
                              fontSize: DesignTokens.fontSizeBase,
                              fontWeight: DesignTokens.fontWeightSemiBold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: DesignTokens.spaceMD),

                      // Already have account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'alreadyHaveAccount'.tr(),
                            style: TextStyle(
                              color: DesignTokens.neutral600,
                              fontSize: DesignTokens.fontSizeBase,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'login'.tr(),
                              style: const TextStyle(
                                color: DesignTokens.primaryBlue,
                                fontWeight: DesignTokens.fontWeightBold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Join as professional
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TechnicianSignupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'joinAsProfessional'.tr(),
                          style: TextStyle(
                            color: DesignTokens.neutral500,
                            fontSize: DesignTokens.fontSizeSM,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      // Language selector
                      const SizedBox(height: DesignTokens.spaceSM),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _LanguageButton(
                            label: 'English',
                            isSelected: context.locale.languageCode == 'en',
                            onTap: () {
                              LocaleProvider.setLanguageCode('en');
                              context.setLocale(const Locale('en'));
                            },
                          ),
                          Container(
                            height: 16,
                            width: 1,
                            color: DesignTokens.neutral300,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          _LanguageButton(
                            label: 'العربية',
                            isSelected: context.locale.languageCode == 'ar',
                            onTap: () {
                              LocaleProvider.setLanguageCode('ar');
                              context.setLocale(const Locale('ar'));
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSlide({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        // Worker image
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceLG,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusXL,
                      ),
                    ),
                    child: const Icon(
                      Icons.engineering,
                      size: 120,
                      color: Colors.white54,
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Title and subtitle
        Padding(
          padding: const EdgeInsets.all(DesignTokens.spaceLG),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: DesignTokens.fontSize2XL,
                  fontWeight: DesignTokens.fontWeightBold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceSM),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: DesignTokens.fontSizeBase,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? DesignTokens.primaryBlue
              : DesignTokens.neutral500,
          fontWeight: isSelected
              ? DesignTokens.fontWeightBold
              : DesignTokens.fontWeightRegular,
          fontSize: DesignTokens.fontSizeSM,
        ),
      ),
    );
  }
}
