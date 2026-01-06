// File: lib/services/in_app_review_service.dart
// Purpose: Service to manage in-app review prompts for app store ratings

import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage in-app review prompts
///
/// Requests app store reviews after successful order completions,
/// following Apple and Google guidelines for review prompts.
class InAppReviewService {
  static const String _completedOrdersKey = 'completed_orders_count';
  static const String _lastReviewPromptKey = 'last_review_prompt';
  static const String _hasReviewedKey = 'has_reviewed';

  /// Minimum completed orders before first review prompt
  static const int _minOrdersForReview = 3;

  /// Days between review prompts if user hasn't reviewed
  static const int _daysBetweenPrompts = 30;

  final InAppReview _inAppReview = InAppReview.instance;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  /// Increment completed orders count and check if review should be requested
  Future<void> onOrderCompleted() async {
    final prefs = await _prefs;
    final count = (prefs.getInt(_completedOrdersKey) ?? 0) + 1;
    await prefs.setInt(_completedOrdersKey, count);

    // Check if eligible for review
    await requestReviewIfEligible();
  }

  /// Request review if the user meets eligibility criteria
  Future<bool> requestReviewIfEligible() async {
    final prefs = await _prefs;

    // Don't prompt if user has already reviewed
    if (prefs.getBool(_hasReviewedKey) ?? false) {
      return false;
    }

    // Check minimum order count
    final completedOrders = prefs.getInt(_completedOrdersKey) ?? 0;
    if (completedOrders < _minOrdersForReview) {
      return false;
    }

    // Check if enough time has passed since last prompt
    final lastPromptMs = prefs.getInt(_lastReviewPromptKey);
    if (lastPromptMs != null) {
      final lastPrompt = DateTime.fromMillisecondsSinceEpoch(lastPromptMs);
      if (DateTime.now().difference(lastPrompt).inDays < _daysBetweenPrompts) {
        return false;
      }
    }

    // Check if in-app review is available
    final isAvailable = await _inAppReview.isAvailable();
    if (!isAvailable) {
      return false;
    }

    // Request review
    try {
      await _inAppReview.requestReview();

      // Record the prompt time
      await prefs.setInt(
        _lastReviewPromptKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Open the app store page directly (fallback for in-app review)
  Future<void> openStoreListing() async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: 'YOUR_APP_STORE_ID', // Replace with actual ID
      );
    } catch (e) {
      // Silently fail - store listing not accessible
    }
  }

  /// Mark that the user has left a review (to stop prompting)
  Future<void> markAsReviewed() async {
    final prefs = await _prefs;
    await prefs.setBool(_hasReviewedKey, true);
  }

  /// Reset review tracking (for testing/debugging)
  Future<void> resetReviewTracking() async {
    final prefs = await _prefs;
    await prefs.remove(_completedOrdersKey);
    await prefs.remove(_lastReviewPromptKey);
    await prefs.remove(_hasReviewedKey);
  }

  /// Get current stats (for debugging)
  Future<Map<String, dynamic>> getStats() async {
    final prefs = await _prefs;
    return {
      'completedOrders': prefs.getInt(_completedOrdersKey) ?? 0,
      'lastPrompt': prefs.getInt(_lastReviewPromptKey),
      'hasReviewed': prefs.getBool(_hasReviewedKey) ?? false,
      'isAvailable': await _inAppReview.isAvailable(),
    };
  }
}
