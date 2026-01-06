// ignore: dangling_library_doc_comments
/// Validation Utilities
///
/// This file provides comprehensive validation utilities for form inputs,
/// business rules, and data integrity checks.

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Validation result
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult({required this.isValid, this.errorMessage});

  factory ValidationResult.valid() {
    return const ValidationResult(isValid: true);
  }

  factory ValidationResult.invalid(String message) {
    return ValidationResult(isValid: false, errorMessage: message);
  }

  @override
  String toString() {
    return isValid ? 'Valid' : 'Invalid: $errorMessage';
  }
}

/// Validation rule
class ValidationRule {
  final String errorMessage;
  final bool Function(String value) validator;

  const ValidationRule(this.errorMessage, this.validator);
}

/// Email validator
class EmailValidator {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static ValidationResult validate(String? email) {
    if (email == null || email.isEmpty) {
      return ValidationResult.invalid('Email is required');
    }

    if (!_emailRegExp.hasMatch(email)) {
      return ValidationResult.invalid('Please enter a valid email address');
    }

    return ValidationResult.valid();
  }
}

/// Password validator
class PasswordValidator {
  static const int minLength = 8;
  static const int maxLength = 128;

  static ValidationResult validate(String? password) {
    if (password == null || password.isEmpty) {
      return ValidationResult.invalid('Password is required');
    }

    if (password.length < minLength) {
      return ValidationResult.invalid(
        'Password must be at least $minLength characters',
      );
    }

    if (password.length > maxLength) {
      return ValidationResult.invalid(
        'Password must not exceed $maxLength characters',
      );
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return ValidationResult.invalid(
        'Password must contain at least one uppercase letter',
      );
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return ValidationResult.invalid(
        'Password must contain at least one lowercase letter',
      );
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return ValidationResult.invalid(
        'Password must contain at least one number',
      );
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return ValidationResult.invalid(
        'Password must contain at least one special character',
      );
    }

    return ValidationResult.valid();
  }

  /// Get password strength
  static PasswordStrength getStrength(String password) {
    int score = 0;

    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }
}

/// Password strength
enum PasswordStrength { weak, medium, strong }

/// Phone number validator
class PhoneValidator {
  static final RegExp _phoneRegExp = RegExp(r'^\+?[\d\s-()]{10,}$');

  static ValidationResult validate(String? phone) {
    if (phone == null || phone.isEmpty) {
      return ValidationResult.invalid('Phone number is required');
    }

    if (!_phoneRegExp.hasMatch(phone)) {
      return ValidationResult.invalid('Please enter a valid phone number');
    }

    return ValidationResult.valid();
  }

  /// Format phone number
  static String format(String phone) {
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Format based on length
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }

    return phone;
  }
}

/// Date validator
class DateValidator {
  static ValidationResult validate(
    String? date, {
    String? format,
    DateTime? minDate,
    DateTime? maxDate,
    bool allowFuture = true,
  }) {
    if (date == null || date.isEmpty) {
      return ValidationResult.invalid('Date is required');
    }

    DateTime? parsedDate;
    try {
      parsedDate = DateFormat(format ?? 'MM/dd/yyyy').parseStrict(date);
    } catch (e) {
      return ValidationResult.invalid('Please enter a valid date');
    }

    if (minDate != null && parsedDate.isBefore(minDate)) {
      return ValidationResult.invalid(
        'Date must be on or after ${DateFormat(format ?? 'MM/dd/yyyy').format(minDate)}',
      );
    }

    if (maxDate != null && parsedDate.isAfter(maxDate)) {
      return ValidationResult.invalid(
        'Date must be on or before ${DateFormat(format ?? 'MM/dd/yyyy').format(maxDate)}',
      );
    }

    if (!allowFuture && parsedDate.isAfter(DateTime.now())) {
      return ValidationResult.invalid('Date cannot be in the future');
    }

    return ValidationResult.valid();
  }
}

/// Number validator
class NumberValidator {
  static ValidationResult validate(
    String? value, {
    double? min,
    double? max,
    bool allowDecimals = true,
    bool allowNegative = true,
  }) {
    if (value == null || value.isEmpty) {
      return ValidationResult.invalid('Value is required');
    }

    final number = double.tryParse(value);
    if (number == null) {
      return ValidationResult.invalid('Please enter a valid number');
    }

    if (!allowDecimals && !number.isFinite) {
      return ValidationResult.invalid('Decimals are not allowed');
    }

    if (!allowNegative && number < 0) {
      return ValidationResult.invalid('Negative values are not allowed');
    }

    if (min != null && number < min) {
      return ValidationResult.invalid('Value must be at least $min');
    }

    if (max != null && number > max) {
      return ValidationResult.invalid('Value must not exceed $max');
    }

    return ValidationResult.valid();
  }
}

/// URL validator
class UrlValidator {
  static final RegExp _urlRegExp = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  static ValidationResult validate(String? url) {
    if (url == null || url.isEmpty) {
      return ValidationResult.invalid('URL is required');
    }

    if (!_urlRegExp.hasMatch(url)) {
      return ValidationResult.invalid('Please enter a valid URL');
    }

    return ValidationResult.valid();
  }
}

/// Credit card validator
class CreditCardValidator {
  static ValidationResult validate(String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) {
      return ValidationResult.invalid('Card number is required');
    }

    // Remove spaces and dashes
    final cleaned = cardNumber.replaceAll(RegExp(r'[\s-]'), '');

    // Check length (13-19 digits)
    if (cleaned.length < 13 || cleaned.length > 19) {
      return ValidationResult.invalid('Invalid card number length');
    }

    // Check if all digits
    if (!cleaned.contains(RegExp(r'^\d+$'))) {
      return ValidationResult.invalid('Card number must contain only digits');
    }

    // Luhn algorithm check
    if (!_luhnCheck(cleaned)) {
      return ValidationResult.invalid('Invalid card number');
    }

    return ValidationResult.valid();
  }

  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;

    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit = (digit % 10) + 1;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return (sum % 10) == 0;
  }

  /// Format card number
  static String format(String cardNumber) {
    final cleaned = cardNumber.replaceAll(RegExp(r'[\s-]'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }

    return buffer.toString();
  }
}

/// Name validator
class NameValidator {
  static final RegExp _nameRegExp = RegExp(r"^[a-zA-Z\s\-']{2,50}$");

  static ValidationResult validate(String? name) {
    if (name == null || name.isEmpty) {
      return ValidationResult.invalid('Name is required');
    }

    if (!_nameRegExp.hasMatch(name)) {
      return ValidationResult.invalid('Please enter a valid name');
    }

    return ValidationResult.valid();
  }
}

/// Address validator
class AddressValidator {
  static final RegExp _addressRegExp = RegExp(r'^[\d\s\w\.\,\-]{5,100}$');

  static ValidationResult validate(String? address) {
    if (address == null || address.isEmpty) {
      return ValidationResult.invalid('Address is required');
    }

    if (!_addressRegExp.hasMatch(address)) {
      return ValidationResult.invalid('Please enter a valid address');
    }

    return ValidationResult.valid();
  }
}

/// Zip code validator
class ZipCodeValidator {
  static final RegExp _usZipRegExp = RegExp(r'^\d{5}(-\d{4})?$');
  static final RegExp _caZipRegExp = RegExp(
    r'^[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d$',
  );

  static ValidationResult validate(String? zipCode, {String? countryCode}) {
    if (zipCode == null || zipCode.isEmpty) {
      return ValidationResult.invalid('Zip code is required');
    }

    RegExp pattern;
    switch (countryCode?.toUpperCase()) {
      case 'CA':
        pattern = _caZipRegExp;
        break;
      case 'US':
      default:
        pattern = _usZipRegExp;
    }

    if (!pattern.hasMatch(zipCode)) {
      return ValidationResult.invalid('Please enter a valid zip code');
    }

    return ValidationResult.valid();
  }
}

/// Text validator
class TextValidator {
  static ValidationResult validate(
    String? text, {
    int? minLength,
    int? maxLength,
    String? pattern,
    bool allowEmpty = false,
  }) {
    if (text == null || text.isEmpty) {
      return allowEmpty
          ? ValidationResult.valid()
          : ValidationResult.invalid('This field is required');
    }

    if (minLength != null && text.length < minLength) {
      return ValidationResult.invalid(
        'Minimum length is $minLength characters',
      );
    }

    if (maxLength != null && text.length > maxLength) {
      return ValidationResult.invalid(
        'Maximum length is $maxLength characters',
      );
    }

    if (pattern != null && !RegExp(pattern).hasMatch(text)) {
      return ValidationResult.invalid('Invalid format');
    }

    return ValidationResult.valid();
  }
}

/// Form validator
class FormValidator {
  final Map<String, ValidationRule> _rules = {};

  /// Add validation rule
  void addRule(String field, ValidationRule rule) {
    _rules[field] = rule;
  }

  /// Remove validation rule
  void removeRule(String field) {
    _rules.remove(field);
  }

  /// Validate field
  ValidationResult validateField(String field, String value) {
    final rule = _rules[field];
    if (rule == null) {
      return ValidationResult.valid();
    }

    return rule.validator(value)
        ? ValidationResult.valid()
        : ValidationResult.invalid(rule.errorMessage);
  }

  /// Validate all fields
  Map<String, ValidationResult> validateAll(Map<String, String> data) {
    final results = <String, ValidationResult>{};

    for (final entry in data.entries) {
      results[entry.key] = validateField(entry.key, entry.value);
    }

    return results;
  }

  /// Check if all fields are valid
  bool areAllValid(Map<String, String> data) {
    final results = validateAll(data);
    return results.values.every((result) => result.isValid);
  }

  /// Clear all rules
  void clear() {
    _rules.clear();
  }
}

/// Input formatter utilities
class InputFormatter {
  /// Phone number formatter
  static TextInputFormatter phoneFormatter = TextInputFormatter.withFunction((
    oldValue,
    newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.length > 10) {
      return oldValue;
    }

    String formatted = '';
    if (text.length >= 3) {
      formatted += '(${text.substring(0, 3)})';
      if (text.length >= 6) {
        formatted += ' ${text.substring(3, 6)}';
        if (text.length >= 10) {
          formatted += '-${text.substring(6, 10)}';
        } else {
          formatted += text.substring(6);
        }
      } else {
        formatted += text.substring(3);
      }
    } else {
      formatted = text;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  });

  /// Credit card formatter
  static TextInputFormatter creditCardFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
        if (text.length > 16) {
          return oldValue;
        }

        final buffer = StringBuffer();
        for (int i = 0; i < text.length; i++) {
          if (i > 0 && i % 4 == 0) {
            buffer.write(' ');
          }
          buffer.write(text[i]);
        }

        return TextEditingValue(
          text: buffer.toString(),
          selection: TextSelection.collapsed(offset: buffer.length),
        );
      });

  /// Decimal number formatter
  static TextInputFormatter decimalFormatter = TextInputFormatter.withFunction((
    oldValue,
    newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final number = double.tryParse(text);
    if (number == null) return oldValue;

    return newValue;
  });

  /// Uppercase formatter
  static TextInputFormatter uppercaseFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        return TextEditingValue(
          text: newValue.text.toUpperCase(),
          selection: newValue.selection,
          composing: newValue.composing,
        );
      });

  /// Lowercase formatter
  static TextInputFormatter lowercaseFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        return TextEditingValue(
          text: newValue.text.toLowerCase(),
          selection: newValue.selection,
          composing: newValue.composing,
        );
      });
}
