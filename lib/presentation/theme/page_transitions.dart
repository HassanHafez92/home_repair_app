import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Custom page transitions for premium navigation experience
class PageTransitions {
  PageTransitions._();

  /// Slide up from bottom - for modal-style screens
  static Widget slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    final tween = Tween(
      begin: begin,
      end: end,
    ).chain(CurveTween(curve: Curves.easeOutCubic));

    return SlideTransition(position: animation.drive(tween), child: child);
  }

  /// Fade with scale - for detail screens
  static Widget fadeScaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    );
    final scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(scale: scaleAnimation, child: child),
    );
  }

  /// Shared axis horizontal - for tab/wizard navigation
  static Widget sharedAxisHorizontalTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slideInAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    final slideOutAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-0.3, 0.0)).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: Curves.easeInCubic,
          ),
        );

    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    return FadeTransition(
      opacity: fadeIn,
      child: SlideTransition(
        position: slideInAnimation,
        child: FadeTransition(
          opacity: fadeOut,
          child: SlideTransition(position: slideOutAnimation, child: child),
        ),
      ),
    );
  }

  /// Fade only - for subtle transitions
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }
}

/// Custom page route with slide up animation
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: PageTransitions.slideUpTransition,
        transitionDuration: DesignTokens.durationNormal,
        reverseTransitionDuration: DesignTokens.durationFast,
      );
}

/// Custom page route with fade + scale animation
class FadeScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadeScalePageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: PageTransitions.fadeScaleTransition,
        transitionDuration: DesignTokens.durationNormal,
        reverseTransitionDuration: DesignTokens.durationFast,
      );
}

/// Custom page route with shared axis horizontal animation
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SharedAxisPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: PageTransitions.sharedAxisHorizontalTransition,
        transitionDuration: DesignTokens.durationNormal,
        reverseTransitionDuration: DesignTokens.durationFast,
      );
}

/// Custom page route with fade animation
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: PageTransitions.fadeTransition,
        transitionDuration: DesignTokens.durationFast,
        reverseTransitionDuration: DesignTokens.durationFast,
      );
}

/// Extension to make navigation with custom transitions easier
extension NavigatorExtensions on NavigatorState {
  /// Push with slide up animation (for modals)
  Future<T?> pushSlideUp<T>(Widget page) {
    return push<T>(SlideUpPageRoute<T>(page: page));
  }

  /// Push with fade + scale animation (for details)
  Future<T?> pushFadeScale<T>(Widget page) {
    return push<T>(FadeScalePageRoute<T>(page: page));
  }

  /// Push with shared axis animation (for wizard steps)
  Future<T?> pushSharedAxis<T>(Widget page) {
    return push<T>(SharedAxisPageRoute<T>(page: page));
  }

  /// Push with simple fade animation
  Future<T?> pushFade<T>(Widget page) {
    return push<T>(FadePageRoute<T>(page: page));
  }
}
