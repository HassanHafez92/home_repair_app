/// Design System - Spacing
///
/// This file defines the spacing scale for the application.
/// All spacing values should be referenced from here to ensure consistency.
library;

import 'package:flutter/widgets.dart';

/// Spacing scale based on 4px base unit
class AppSpacing {
  // Base spacing unit
  static const double unit = 4.0;

  // Spacing scale
  static const double xs = unit * 1; // 4px
  static const double sm = unit * 2; // 8px
  static const double md = unit * 3; // 12px
  static const double lg = unit * 4; // 16px
  static const double xl = unit * 5; // 20px
  static const double xxl = unit * 6; // 24px
  static const double xxxl = unit * 8; // 32px
  static const double huge = unit * 10; // 40px
  static const double massive = unit * 12; // 48px

  // Special spacing values
  static const double screenPadding = lg; // 16px - Default screen padding
  static const double cardPadding = lg; // 16px - Default card padding
  static const double sectionSpacing = xxl; // 24px - Section spacing
  static const double listSpacing = md; // 12px - List item spacing
  static const double buttonPadding = md; // 12px - Button padding
  static const double inputPadding = md; // 12px - Input field padding
}

/// Edge insets helpers
class AppEdgeInsets {
  // All sides
  static const EdgeInsets all = EdgeInsets.all(AppSpacing.lg);
  static const EdgeInsets allSmall = EdgeInsets.all(AppSpacing.sm);
  static const EdgeInsets allLarge = EdgeInsets.all(AppSpacing.xxl);

  // Horizontal
  static const EdgeInsets horizontal = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
  );
  static const EdgeInsets horizontalSmall = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
  );
  static const EdgeInsets horizontalLarge = EdgeInsets.symmetric(
    horizontal: AppSpacing.xxl,
  );

  // Vertical
  static const EdgeInsets vertical = EdgeInsets.symmetric(
    vertical: AppSpacing.lg,
  );
  static const EdgeInsets verticalSmall = EdgeInsets.symmetric(
    vertical: AppSpacing.md,
  );
  static const EdgeInsets verticalLarge = EdgeInsets.symmetric(
    vertical: AppSpacing.xxl,
  );

  // Specific sides
  static const EdgeInsets top = EdgeInsets.only(top: AppSpacing.lg);
  static const EdgeInsets bottom = EdgeInsets.only(bottom: AppSpacing.lg);
  static const EdgeInsets left = EdgeInsets.only(left: AppSpacing.lg);
  static const EdgeInsets right = EdgeInsets.only(right: AppSpacing.lg);

  // Combinations
  static const EdgeInsets topBottom = EdgeInsets.only(
    top: AppSpacing.lg,
    bottom: AppSpacing.lg,
  );

  static const EdgeInsets leftRight = EdgeInsets.only(
    left: AppSpacing.lg,
    right: AppSpacing.lg,
  );

  // Card padding
  static const EdgeInsets card = EdgeInsets.all(AppSpacing.cardPadding);

  // List item padding
  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.md,
  );

  // Button padding
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
    vertical: AppSpacing.md,
  );

  // Input field padding
  static const EdgeInsets input = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.md,
  );
}

/// SizedBox helpers for spacing
class AppSizedBox {
  // Height helpers
  static const SizedBox heightXS = SizedBox(height: AppSpacing.xs);
  static const SizedBox heightSM = SizedBox(height: AppSpacing.sm);
  static const SizedBox heightMD = SizedBox(height: AppSpacing.md);
  static const SizedBox heightLG = SizedBox(height: AppSpacing.lg);
  static const SizedBox heightXL = SizedBox(height: AppSpacing.xl);
  static const SizedBox heightXXL = SizedBox(height: AppSpacing.xxl);
  static const SizedBox heightXXXL = SizedBox(height: AppSpacing.xxxl);
  static const SizedBox heightHuge = SizedBox(height: AppSpacing.huge);
  static const SizedBox heightMassive = SizedBox(height: AppSpacing.massive);

  // Width helpers
  static const SizedBox widthXS = SizedBox(width: AppSpacing.xs);
  static const SizedBox widthSM = SizedBox(width: AppSpacing.sm);
  static const SizedBox widthMD = SizedBox(width: AppSpacing.md);
  static const SizedBox widthLG = SizedBox(width: AppSpacing.lg);
  static const SizedBox widthXL = SizedBox(width: AppSpacing.xl);
  static const SizedBox widthXXL = SizedBox(width: AppSpacing.xxl);
  static const SizedBox widthXXXL = SizedBox(width: AppSpacing.xxxl);
  static const SizedBox widthHuge = SizedBox(width: AppSpacing.huge);
  static const SizedBox widthMassive = SizedBox(width: AppSpacing.massive);

  // Expanded spacing
  static const Widget expanded = Expanded(child: SizedBox.shrink());

  // Spacers
  static const Widget spacer = Spacer();
}

/// Gap helper for creating consistent spacing between widgets
class Gap extends StatelessWidget {
  final double size;

  const Gap(this.size, {super.key});

  factory Gap.xs() => const Gap(AppSpacing.xs);
  factory Gap.sm() => const Gap(AppSpacing.sm);
  factory Gap.md() => const Gap(AppSpacing.md);
  factory Gap.lg() => const Gap(AppSpacing.lg);
  factory Gap.xl() => const Gap(AppSpacing.xl);
  factory Gap.xxl() => const Gap(AppSpacing.xxl);
  factory Gap.xxxl() => const Gap(AppSpacing.xxxl);
  factory Gap.huge() => const Gap(AppSpacing.huge);
  factory Gap.massive() => const Gap(AppSpacing.massive);

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: size, width: size);
  }
}
