// File: lib/services/locale_provider.dart
// Purpose: Global locale provider for accessing current app locale in data layer.

/// Global locale provider that can be accessed from the data layer.
/// This is updated by the app when the locale changes via easy_localization.
class LocaleProvider {
  static String _currentLanguageCode = 'en';

  /// Get the current language code (e.g., 'en', 'ar')
  static String get currentLanguageCode => _currentLanguageCode;

  /// Check if current locale is Arabic
  static bool get isArabic => _currentLanguageCode == 'ar';

  /// Update the current language code (called when locale changes)
  static void setLanguageCode(String languageCode) {
    _currentLanguageCode = languageCode;
  }
}
