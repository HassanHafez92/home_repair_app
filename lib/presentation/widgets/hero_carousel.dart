import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../theme/design_tokens.dart';

/// Data model for a carousel slide
class CarouselSlide {
  final String titleKey;
  final String subtitleKey;
  final String? ctaTextKey;
  final Color gradientStart;
  final Color gradientEnd;
  final IconData icon;
  final VoidCallback? onTap;

  const CarouselSlide({
    required this.titleKey,
    required this.subtitleKey,
    this.ctaTextKey,
    required this.gradientStart,
    required this.gradientEnd,
    required this.icon,
    this.onTap,
  });
}

/// A hero carousel widget with auto-rotation and dot indicators
/// Inspired by Fixawy's homepage hero section
class HeroCarousel extends StatefulWidget {
  final List<CarouselSlide> slides;
  final Duration autoPlayDuration;
  final double height;
  final VoidCallback? onSlideCtaTap;

  const HeroCarousel({
    super.key,
    required this.slides,
    this.autoPlayDuration = const Duration(seconds: 5),
    this.height = 200,
    this.onSlideCtaTap,
  });

  /// Creates a default carousel with promotional slides
  factory HeroCarousel.withDefaultSlides({Key? key, VoidCallback? onCtaTap}) {
    return HeroCarousel(
      key: key,
      onSlideCtaTap: onCtaTap,
      slides: [
        CarouselSlide(
          titleKey: 'carouselSlide1Title',
          subtitleKey: 'carouselSlide1Subtitle',
          ctaTextKey: 'bookNow',
          gradientStart: DesignTokens.primaryBlue,
          gradientEnd: DesignTokens.primaryBlueDark,
          icon: Icons.build_rounded,
        ),
        CarouselSlide(
          titleKey: 'carouselSlide2Title',
          subtitleKey: 'carouselSlide2Subtitle',
          ctaTextKey: 'viewDetails',
          gradientStart: DesignTokens.accentOrange,
          gradientEnd: const Color(0xFFD97706),
          icon: Icons.local_offer_rounded,
        ),
        CarouselSlide(
          titleKey: 'carouselSlide3Title',
          subtitleKey: 'carouselSlide3Subtitle',
          ctaTextKey: 'bookNow',
          gradientStart: DesignTokens.accentGreen,
          gradientEnd: const Color(0xFF059669),
          icon: Icons.emergency_rounded,
        ),
      ],
    );
  }

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(widget.autoPlayDuration, (_) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % widget.slides.length;
        _pageController.animateToPage(
          nextPage,
          duration: DesignTokens.durationNormal,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Carousel
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.slides.length,
            itemBuilder: (context, index) {
              return _CarouselSlideWidget(
                slide: widget.slides[index],
                onCtaTap: widget.onSlideCtaTap,
              );
            },
          ),
        ),
        const SizedBox(height: DesignTokens.spaceMD),
        // Dot Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.slides.length,
            (index) => AnimatedContainer(
              duration: DesignTokens.durationFast,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CarouselSlideWidget extends StatelessWidget {
  final CarouselSlide slide;
  final VoidCallback? onCtaTap;

  const _CarouselSlideWidget({required this.slide, this.onCtaTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DesignTokens.spaceXS),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        gradient: LinearGradient(
          colors: [slide.gradientStart, slide.gradientEnd],
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

          // Content
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
                      Text(
                        slide.titleKey.tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: DesignTokens.fontWeightBold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.spaceXS),
                      Text(
                        slide.subtitleKey.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (slide.ctaTextKey != null) ...[
                        const SizedBox(height: DesignTokens.spaceMD),
                        ElevatedButton(
                          onPressed: onCtaTap ?? slide.onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: slide.gradientStart,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                DesignTokens.radiusSM,
                              ),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignTokens.spaceLG,
                              vertical: DesignTokens.spaceSM,
                            ),
                          ),
                          child: Text(
                            slide.ctaTextKey!.tr(),
                            style: TextStyle(
                              fontWeight: DesignTokens.fontWeightBold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Icon
                Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      slide.icon,
                      size: 80,
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
