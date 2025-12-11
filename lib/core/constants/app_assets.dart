// Application asset constants
//
// Centralized location for all asset paths to ensure type-safety
// and prevent runtime errors from typos.
class AppAssets {
  AppAssets._(); // Private constructor to prevent instantiation

  // Base paths
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _translationsPath = 'assets/translations';

  // Images
  static const String onboarding1 = '$_imagesPath/onboarding1.png';
  static const String onboarding2 = '$_imagesPath/onboarding2.png';
  static const String onboarding3 = '$_imagesPath/onboarding3.png';
  static const String userPlaceholder = '$_imagesPath/user.jpg';

  // Translations
  static const String translationsPath = _translationsPath;
  static const String translationsEnglish = '$_translationsPath/en.json';
  static const String translationsArabic = '$_translationsPath/ar.json';

  // Icons (if needed)
  static const String iconsPath = _iconsPath;
}
