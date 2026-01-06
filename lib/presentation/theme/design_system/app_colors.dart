/// Design System - Color Palette
///
/// This file defines the complete color system for the application.
/// All colors should be referenced from here to ensure consistency.
library;

import 'package:flutter/material.dart';

/// Primary Colors - Main brand colors
class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);

  // Secondary brand colors
  static const Color secondary = Color(0xFF009688);
  static const Color secondaryLight = Color(0xFF4DB6AC);
  static const Color secondaryDark = Color(0xFF00796B);

  // Accent colors
  static const Color accent = Color(0xFFFF9800);
  static const Color accentLight = Color(0xFFFFB74D);
  static const Color accentDark = Color(0xFFE65100);
}

/// Semantic Colors - Used for conveying meaning
class SemanticColors {
  // Success states
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);
  static const Color successBackground = Color(0xFFE8F5E9);

  // Warning states
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFE65100);
  static const Color warningBackground = Color(0xFFFFF3E0);

  // Error states
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color errorBackground = Color(0xFFFFEBEE);

  // Info states
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoDark = Color(0xFF1976D2);
  static const Color infoBackground = Color(0xFFE3F2FD);
}

/// Neutral Colors - Used for text, backgrounds, and borders
class NeutralColors {
  // White and black
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Gray scale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);
}

/// Surface Colors - Used for backgrounds and cards
class SurfaceColors {
  static const Color surface = NeutralColors.white;
  static const Color surfaceVariant = NeutralColors.gray50;
  static const Color surfaceDisabled = NeutralColors.gray100;
  static const Color surfaceElevated = NeutralColors.white;
}

/// Text Colors - Used for typography
class TextColors {
  // Primary text
  static const Color primary = NeutralColors.gray900;
  static const Color secondary = NeutralColors.gray600;
  static const Color tertiary = NeutralColors.gray400;
  static const Color disabled = NeutralColors.gray300;
  static const Color inverse = NeutralColors.white;

  // Links
  static const Color link = AppColors.primary;
  static const Color linkVisited = AppColors.primaryDark;
}

/// Border Colors - Used for borders and dividers
class BorderColors {
  static const Color default_ = NeutralColors.gray300;
  static const Color light = NeutralColors.gray200;
  static const Color dark = NeutralColors.gray400;
  static const Color focus = AppColors.primary;
  static const Color error = SemanticColors.error;
  static const Color success = SemanticColors.success;
}

/// Shadow Colors - Used for elevation
class ShadowColors {
  static const Color shadow = Color(0x1A000000); // 10% black
  static const Color shadowLight = Color(0x0D000000); // 5% black
  static const Color shadowDark = Color(0x26000000); // 15% black
}

/// Overlay Colors - Used for overlays and modals
class OverlayColors {
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color overlayLight = Color(0x40000000); // 25% black
  static const Color overlayDark = Color(0x99000000); // 60% black
}
