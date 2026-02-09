/// Professional Spacing System
/// Single source of truth for all spacing values
class Spacing {
  // Base unit: 4px
  static const double base = 4.0;

  // Spacing scale
  static const double xxs = base; // 4px
  static const double xs = base * 2; // 8px
  static const double sm = base * 3; // 12px
  static const double md = base * 4; // 16px
  static const double lg = base * 6; // 24px
  static const double xl = base * 8; // 32px
  static const double xxl = base * 12; // 48px
  static const double xxxl = base * 16; // 64px

  // Component-specific
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 40.0;
  static const double inputHeight = 56.0;
  static const double iconSize = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double navBarHeight = 64.0;

  // Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;
}
