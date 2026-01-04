// File: lib/presentation/widgets/app_toast.dart
// Purpose: Reusable toast notifications with success, error, and info variants

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';

/// Toast variant types
enum ToastVariant { success, error, warning, info }

/// Material-inspired toast notifications with animations
class AppToast {
  AppToast._();

  /// Show a toast notification
  static void show(
    BuildContext context, {
    required String message,
    ToastVariant variant = ToastVariant.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    // Haptic feedback based on variant
    switch (variant) {
      case ToastVariant.success:
        HapticFeedback.lightImpact();
        break;
      case ToastVariant.error:
        HapticFeedback.heavyImpact();
        break;
      case ToastVariant.warning:
        HapticFeedback.mediumImpact();
        break;
      case ToastVariant.info:
        HapticFeedback.selectionClick();
        break;
    }

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        variant: variant,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: () => entry.remove(),
        duration: duration,
      ),
    );

    overlay.insert(entry);
  }

  /// Convenience methods
  static void success(BuildContext context, String message) {
    show(context, message: message, variant: ToastVariant.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, variant: ToastVariant.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, variant: ToastVariant.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, variant: ToastVariant.info);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastVariant variant;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.variant,
    this.actionLabel,
    this.onAction,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DesignTokens.durationNormal,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, _dismiss);
  }

  void _dismiss() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.variant) {
      case ToastVariant.success:
        return DesignTokens.success;
      case ToastVariant.error:
        return DesignTokens.error;
      case ToastVariant.warning:
        return DesignTokens.warning;
      case ToastVariant.info:
        return DesignTokens.primaryBlue;
    }
  }

  IconData get _icon {
    switch (widget.variant) {
      case ToastVariant.success:
        return Icons.check_circle_rounded;
      case ToastVariant.error:
        return Icons.error_rounded;
      case ToastVariant.warning:
        return Icons.warning_rounded;
      case ToastVariant.info:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: DesignTokens.spaceMD,
      right: DesignTokens.spaceMD,
      bottom: MediaQuery.of(context).padding.bottom + DesignTokens.spaceLG,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceMD,
                vertical: DesignTokens.spaceSM,
              ),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(DesignTokens.radiusMD),
                boxShadow: DesignTokens.shadowMedium,
              ),
              child: Row(
                children: [
                  Icon(_icon, color: Colors.white, size: 22),
                  const SizedBox(width: DesignTokens.spaceSM),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (widget.actionLabel != null &&
                      widget.onAction != null) ...[
                    const SizedBox(width: DesignTokens.spaceSM),
                    TextButton(
                      onPressed: () {
                        widget.onAction?.call();
                        _dismiss();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.spaceSM,
                        ),
                      ),
                      child: Text(
                        widget.actionLabel!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: _dismiss,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated success checkmark widget
class SuccessAnimation extends StatefulWidget {
  final double size;
  final VoidCallback? onComplete;

  const SuccessAnimation({super.key, this.size = 100, this.onComplete});

  @override
  State<SuccessAnimation> createState() => _SuccessAnimationState();
}

class _SuccessAnimationState extends State<SuccessAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      HapticFeedback.lightImpact();
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: DesignTokens.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.success.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _CheckPainter(progress: _checkAnimation.value),
            ),
          ),
        );
      },
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;

  _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = size.width / 2;

    // Checkmark path points
    final start = Offset(center * 0.5, center);
    final mid = Offset(center * 0.85, center * 1.35);
    final end = Offset(center * 1.5, center * 0.65);

    final path = Path();

    if (progress <= 0.5) {
      // First stroke (start to mid)
      final t = progress * 2;
      path.moveTo(start.dx, start.dy);
      path.lineTo(
        start.dx + (mid.dx - start.dx) * t,
        start.dy + (mid.dy - start.dy) * t,
      );
    } else {
      // Complete first stroke
      path.moveTo(start.dx, start.dy);
      path.lineTo(mid.dx, mid.dy);

      // Second stroke (mid to end)
      final t = (progress - 0.5) * 2;
      path.lineTo(
        mid.dx + (end.dx - mid.dx) * t,
        mid.dy + (end.dy - mid.dy) * t,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
