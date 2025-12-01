// File: lib/utils/validators.dart
// Purpose: Input validation utilities for forms and user input

class Validators {
  /// Private constructor to prevent instantiation
  Validators._();

  // ========== Email Validation ==========

  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value!)) {
      return 'Invalid email format';
    }

    return null;
  }

  // ========== Password Validation ==========

  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }

    if ((value?.length ?? 0) < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value!)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value?.isEmpty ?? true) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // ========== Name Validation ==========

  static String? validateName(String? value, {String fieldName = 'Name'}) {
    if (value?.isEmpty ?? true) {
      return '$fieldName is required';
    }

    if ((value?.length ?? 0) < 2) {
      return '$fieldName must be at least 2 characters';
    }

    if ((value?.length ?? 0) > 50) {
      return '$fieldName must not exceed 50 characters';
    }

    if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value!)) {
      return '$fieldName can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // ========== Phone Number Validation ==========

  static String? validatePhoneNumber(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Phone number is required';
    }

    final cleanedValue = value!.replaceAll(RegExp(r'[\s\-\(\)\.+]'), '');

    if (cleanedValue.length < 9 || cleanedValue.length > 15) {
      return 'Phone number must be between 9 and 15 digits';
    }

    if (!RegExp(r'^[0-9+]+$').hasMatch(cleanedValue)) {
      return 'Phone number can only contain digits and +';
    }

    return null;
  }

  static String formatPhoneNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleaned.isEmpty) return value;

    if (!cleaned.startsWith('+') && cleaned.startsWith('00')) {
      return '+${cleaned.substring(2)}';
    }

    return cleaned;
  }

  // ========== Address Validation ==========

  static String? validateAddress(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Address is required';
    }

    if ((value?.length ?? 0) < 5) {
      return 'Address must be at least 5 characters';
    }

    if ((value?.length ?? 0) > 200) {
      return 'Address must not exceed 200 characters';
    }

    return null;
  }

  static String? validateCity(String? value) {
    if (value?.isEmpty ?? true) {
      return 'City is required';
    }

    if ((value?.length ?? 0) < 2) {
      return 'City must be at least 2 characters';
    }

    if ((value?.length ?? 0) > 50) {
      return 'City must not exceed 50 characters';
    }

    return null;
  }

  static String? validateZipCode(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Zip code is required';
    }

    if (!RegExp(r'^[0-9]{5,10}$').hasMatch(value!)) {
      return 'Zip code must be 5-10 digits';
    }

    return null;
  }

  // ========== General Validation ==========

  static String? validateRequired(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value?.isEmpty ?? true) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateMinLength(
    String? value, {
    required int minLength,
    String fieldName = 'Field',
  }) {
    if (value?.isEmpty ?? true) {
      return '$fieldName is required';
    }

    if ((value?.length ?? 0) < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  static String? validateMaxLength(
    String? value, {
    required int maxLength,
    String fieldName = 'Field',
  }) {
    if ((value?.length ?? 0) > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }

    return null;
  }

  static String? validateRange(
    String? value, {
    required int minLength,
    required int maxLength,
    String fieldName = 'Field',
  }) {
    if (value?.isEmpty ?? true) {
      return '$fieldName is required';
    }

    final length = value!.length;
    if (length < minLength || length > maxLength) {
      return '$fieldName must be between $minLength and $maxLength characters';
    }

    return null;
  }

  // ========== URL Validation ==========

  static String? validateUrl(String? value) {
    if (value?.isEmpty ?? true) {
      return 'URL is required';
    }

    try {
      Uri.parse(value!);
      return null;
    } catch (e) {
      return 'Invalid URL format';
    }
  }

  // ========== Rating Validation ==========

  static String? validateRating(int? value, {int maxRating = 5}) {
    if (value == null) {
      return 'Rating is required';
    }

    if (value < 1 || value > maxRating) {
      return 'Rating must be between 1 and $maxRating';
    }

    return null;
  }

  // ========== Price Validation ==========

  static String? validatePrice(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Price is required';
    }

    final priceRegex = RegExp(r'^[0-9]+(\.[0-9]{1,2})?$');
    if (!priceRegex.hasMatch(value!)) {
      return 'Price must be a valid number (up to 2 decimal places)';
    }

    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Price must be greater than 0';
    }

    return null;
  }
}
