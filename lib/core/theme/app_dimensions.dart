import 'package:flutter/material.dart';

/// Complete dimension system for CalorieWala
class AppDimensions {
  // === SPACING SCALE (4px base unit) ===
  static const double xxxs = 2.0; // 0.5x
  static const double xxs = 4.0; // 1x
  static const double xs = 8.0; // 2x
  static const double sm = 12.0; // 3x
  static const double md = 16.0; // 4x
  static const double lg = 24.0; // 6x
  static const double xl = 32.0; // 8x
  static const double xxl = 48.0; // 12x
  static const double xxxl = 64.0; // 16x

  // === BORDER RADIUS ===
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 32.0;
  static const double radiusFull = 999.0;

  // === ICON SIZES ===
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;

  // === BUTTON HEIGHTS ===
  static const double buttonSm = 40.0;
  static const double buttonMd = 48.0;
  static const double buttonLg = 56.0;

  // === FAB SIZES ===
  static const double fabNormal = 56.0;
  static const double fabSmall = 40.0;
  static const double fabLarge = 96.0;

  // === APPBAR ===
  static const double appBarHeight = 56.0;
  static const double appBarExpandedHeight = 120.0;

  // === BOTTOM NAV ===
  static const double bottomNavHeight = 64.0;

  // === ELEVATION ===
  static const double elevation0 = 0.0;
  static const double elevation1 = 2.0;
  static const double elevation2 = 4.0;
  static const double elevation3 = 8.0;
  static const double elevation4 = 12.0;
  static const double elevation5 = 16.0;

  // === EDGE INSETS ===
  static const EdgeInsets paddingZero = EdgeInsets.zero;
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalXs = EdgeInsets.symmetric(
    horizontal: xs,
  );
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(
    horizontal: sm,
  );
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(
    horizontal: lg,
  );

  static const EdgeInsets paddingVerticalXs = EdgeInsets.symmetric(
    vertical: xs,
  );
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(
    vertical: sm,
  );
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(
    vertical: md,
  );
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(
    vertical: lg,
  );

  // === SIZED BOXES (Convenience) ===
  static const SizedBox gapXs = SizedBox(height: xs, width: xs);
  static const SizedBox gapSm = SizedBox(height: sm, width: sm);
  static const SizedBox gapMd = SizedBox(height: md, width: md);
  static const SizedBox gapLg = SizedBox(height: lg, width: lg);
  static const SizedBox gapXl = SizedBox(height: xl, width: xl);
}
