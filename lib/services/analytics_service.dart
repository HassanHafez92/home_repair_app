// File: lib/services/analytics_service.dart
// Purpose: Firebase Analytics integration for tracking user behavior and events

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get FirebaseAnalytics instance for observers
  FirebaseAnalytics get analytics => _analytics;

  /// Get observer for route tracking
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ============ Screen View Tracking ============

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      debugPrint('📊 Analytics: Screen view - $screenName');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ============ Authentication Events ============

  /// Log user signup
  Future<void> logSignup({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      debugPrint('📊 Analytics: Sign up - $method');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log user login
  Future<void> logLogin({required String method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      debugPrint('📊 Analytics: Login - $method');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Set user ID for analytics
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      debugPrint('📊 Analytics: User ID set - $userId');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Set user role property
  Future<void> setUserRole(String role) async {
    try {
      await _analytics.setUserProperty(name: 'user_role', value: role);
      debugPrint('📊 Analytics: User role - $role');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ============ Email Verification Funnel ============

  /// Log email verification started (sent)
  Future<void> logEmailVerificationSent({required String userId}) async {
    try {
      await _analytics.logEvent(
        name: 'email_verification_sent',
        parameters: {
          'user_id': userId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 Analytics: Email verification sent - $userId');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log email verification completed
  Future<void> logEmailVerificationCompleted({required String userId}) async {
    try {
      await _analytics.logEvent(
        name: 'email_verified',
        parameters: {
          'user_id': userId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 Analytics: Email verified - $userId');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log email verification skipped/canceled
  Future<void> logEmailVerificationSkipped({required String userId}) async {
    try {
      await _analytics.logEvent(
        name: 'email_verification_skipped',
        parameters: {'user_id': userId},
      );
      debugPrint('📊 Analytics: Email verification skipped - $userId');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log email resend requested
  Future<void> logEmailVerificationResent({required String userId}) async {
    try {
      await _analytics.logEvent(
        name: 'email_verification_resent',
        parameters: {
          'user_id': userId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      debugPrint('📊 Analytics: Email verification resent - $userId');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log first booking after verification (conversion)
  Future<void> logFirstBookingAfterVerification({
    required String userId,
    required String orderId,
    required double value,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'first_booking_verified_user',
        parameters: {
          'user_id': userId,
          'order_id': orderId,
          'value': value,
          'currency': 'USD',
        },
      );
      debugPrint('📊 Analytics: First booking (verified user) - $orderId');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ============ Service & Booking Events ============

  /// Log service viewed
  Future<void> logServiceViewed({
    required String serviceId,
    required String serviceName,
    required String category,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'service_viewed',
        parameters: {
          'service_id': serviceId,
          'service_name': serviceName,
          'category': category,
        },
      );
      debugPrint('📊 Analytics: Service viewed - $serviceName');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log booking initiated
  Future<void> logBookingInitiated({
    required String serviceId,
    required String serviceName,
    required double price,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'booking_initiated',
        parameters: {
          'service_id': serviceId,
          'service_name': serviceName,
          'price': price,
          'currency': 'USD',
        },
      );
      debugPrint('📊 Analytics: Booking initiated - $serviceName');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log booking completed
  Future<void> logBookingCompleted({
    required String orderId,
    required String serviceId,
    required double price,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'booking_completed',
        parameters: {
          'order_id': orderId,
          'service_id': serviceId,
          'price': price,
          'currency': 'USD',
        },
      );
      debugPrint('📊 Analytics: Booking completed - $orderId');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log booking cancelled
  Future<void> logBookingCancelled({
    required String orderId,
    required String reason,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'booking_cancelled',
        parameters: {'order_id': orderId, 'reason': reason},
      );
      debugPrint('📊 Analytics: Booking cancelled - $orderId');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ============ Search Events ============

  /// Log search performed
  Future<void> logSearch({required String searchTerm, String? category}) async {
    try {
      await _analytics.logSearch(
        searchTerm: searchTerm,
        parameters: category != null ? {'category': category} : null,
      );
      debugPrint('📊 Analytics: Search - $searchTerm');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ============ Contact Events ============

  /// Log call to customer
  Future<void> logCallCustomer({required String orderId}) async {
    try {
      await _analytics.logEvent(
        name: 'call_customer',
        parameters: {'order_id': orderId},
      );
      debugPrint('📊 Analytics: Call customer - $orderId');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log WhatsApp contact to customer
  Future<void> logWhatsAppContact({required String orderId}) async {
    try {
      await _analytics.logEvent(
        name: 'whatsapp_contact',
        parameters: {'order_id': orderId},
      );
      debugPrint('📊 Analytics: WhatsApp contact - $orderId');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ============ Order Events (Technician) ============

  /// Log order accepted by technician
  Future<void> logOrderAccepted({
    required String orderId,
    required String technicianId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'order_accepted',
        parameters: {'order_id': orderId, 'technician_id': technicianId},
      );
      debugPrint('📊 Analytics: Order accepted - $orderId');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Log order completed by technician
  Future<void> logOrderCompleted({
    required String orderId,
    required double finalPrice,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'order_completed',
        parameters: {
          'order_id': orderId,
          'final_price': finalPrice,
          'currency': 'USD',
        },
      );
      debugPrint('📊 Analytics: Order completed - $orderId');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ============ Review Events ============

  /// Log review submitted
  Future<void> logReviewSubmitted({
    required String orderId,
    required String technicianId,
    required double rating,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'review_submitted',
        parameters: {
          'order_id': orderId,
          'technician_id': technicianId,
          'rating': rating,
        },
      );
      debugPrint('📊 Analytics: Review submitted - Rating: $rating');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ============ Error & Exception Events ============

  /// Log error event
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'error_occurred',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          if (stackTrace != null) 'stack_trace': stackTrace,
        },
      );
      debugPrint('📊 Analytics: Error - $errorType');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ============ Custom Events ============

  /// Log custom event
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: eventName, parameters: parameters);
      debugPrint('📊 Analytics: Custom event - $eventName');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  // ============ App Lifecycle Events ============

  /// Log app open
  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
      debugPrint('📊 Analytics: App opened');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Set analytics collection enabled/disabled
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      debugPrint(
        '📊 Analytics: Collection ${enabled ? "enabled" : "disabled"}',
      );
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }
}
