import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:home_repair_app/domain/entities/service_entity.dart';
import '../theme/design_tokens.dart';

class ServiceCard extends StatefulWidget {
  final ServiceEntity service;
  final VoidCallback onTap;
  final IconData? iconData;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.iconData,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  bool get _isPhotoUrl {
    final url = widget.service.iconUrl.toLowerCase();
    return url.contains('unsplash.com') || url.contains('pexels.com');
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Book ${widget.service.name} service',
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: _isPhotoUrl
              ? _buildPhotoCard(context)
              : _buildIconCard(context),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        boxShadow: DesignTokens.shadowSoft,
        image: DecorationImage(
          image: CachedNetworkImageProvider(widget.service.iconUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.8),
            ],
            stops: const [0.5, 0.7, 1.0],
          ),
        ),
        padding: const EdgeInsets.all(DesignTokens.spaceSM),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Badge (Top Right)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceXS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
                ),
                child: Text(
                  'fromPrice'.tr(
                    namedArgs: {
                      'price': widget.service.minPrice.toInt().toString(),
                    },
                  ),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: DesignTokens.fontWeightBold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Title
            Text(
              widget.service.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: DesignTokens.fontWeightBold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLG),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: DesignTokens.shadowSoft,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceSM,
        vertical: DesignTokens.spaceBase,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(DesignTokens.spaceSM),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.iconData ?? Icons.build_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: DesignTokens.iconSizeMD,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXS),
          // Price Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceXS,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusXS),
            ),
            child: Text(
              'fromPrice'.tr(
                namedArgs: {
                  'price': widget.service.minPrice.toInt().toString(),
                },
              ),
              style: TextStyle(
                fontSize: 10,
                fontWeight: DesignTokens.fontWeightSemiBold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXXS),
          // Text
          Text(
            widget.service.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: DesignTokens.fontWeightBold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
