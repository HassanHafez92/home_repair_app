// File: lib/utils/error_message_helper.dart
// Purpose: Provide user-friendly, actionable error messages

class ErrorMessageHelper {
  /// Convert technical errors to user-friendly messages with actionable guidance
  static String getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      return 'Connection issue. Please check your internet and try again.';
    }

    // Firebase Auth errors
    if (errorString.contains('user-not-found')) {
      return 'No account found with this email. Please check and try again.';
    }
    if (errorString.contains('wrong-password')) {
      return 'Incorrect password. Please try again or reset your password.';
    }
    if (errorString.contains('email-already-in-use')) {
      return 'This email is already registered. Try logging in instead.';
    }
    if (errorString.contains('weak-password')) {
      return 'Password is too weak. Use at least 8 characters with letters and numbers.';
    }
    if (errorString.contains('invalid-email')) {
      return 'Invalid email format. Please check your email address.';
    }
    if (errorString.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a few minutes and try again.';
    }
    if (errorString.contains('requires-recent-login')) {
      return 'For security, please log out and log back in before making this change.';
    }

    // Firestore errors
    if (errorString.contains('permission-denied')) {
      return 'Access denied. Please contact support if this persists.';
    }
    if (errorString.contains('not-found')) {
      return 'The requested data was not found. It may have been deleted.';
    }
    if (errorString.contains('already-exists')) {
      return 'This item already exists. Please use a different value.';
    }

    // Storage errors
    if (errorString.contains('storage')) {
      if (errorString.contains('quota')) {
        return 'Storage limit reached. Please delete some files and try again.';
      }
      return 'File upload failed. Please check file size and try again.';
    }

    // Permission errors
    if (errorString.contains('permission')) {
      return 'Permission required. Please enable the necessary permissions in Settings.';
    }

    // Timeout errors
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    }

    // Default fallback
    return 'Something went wrong. Please try again or contact support.';
  }

  /// Get actionable steps for common errors
  static List<String> getActionableSteps(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return [
        'Check your internet connection',
        'Try switching between WiFi and mobile data',
        'Restart the app',
      ];
    }

    if (errorString.contains('permission')) {
      return [
        'Open device Settings',
        'Navigate to Apps → Home Repair',
        'Enable the required permissions',
        'Return to the app and try again',
      ];
    }

    if (errorString.contains('storage') && errorString.contains('quota')) {
      return [
        'Delete unnecessary files or photos',
        'Clear app cache in Settings',
        'Free up device storage',
      ];
    }

    if (errorString.contains('requires-recent-login')) {
      return [
        'Log out from your account',
        'Log back in with your credentials',
        'Try the operation again',
      ];
    }

    return [
      'Close and restart the app',
      'Check your internet connection',
      'Contact support if the issue persists',
    ];
  }

  /// Get support contact based on error type
  static String getSupportGuidance(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('payment') ||
        errorString.contains('transaction')) {
      return 'For payment issues, contact support immediately at support@homerepair.com';
    }

    if (errorString.contains('account') || errorString.contains('auth')) {
      return 'For account issues, reach out to accounts@homerepair.com';
    }

    return 'If the problem continues, contact support@homerepair.com';
  }
}
