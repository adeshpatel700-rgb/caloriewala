/// Consistent spacing and sizing constants throughout the app
class AppSpacing {
  // Base spacing unit (8px grid system)
  static const double unit = 8.0;

  // Spacing scale
  static const double xs = unit * 0.5; // 4px
  static const double sm = unit; // 8px
  static const double md = unit * 2; // 16px
  static const double lg = unit * 3; // 24px
  static const double xl = unit * 4; // 32px
  static const double xxl = unit * 6; // 48px

  // Component spacing
  static const double cardPadding = md;
  static const double screenPadding = md;
  static const double buttonHeight = 56.0;
  static const double iconSize = 24.0;
  static const double iconSizeLarge = 32.0;

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // Elevation (shadows)
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
}

/// Typography scale
class AppTypography {
  // Font sizes
  static const double displayLarge = 32.0;
  static const double displayMedium = 28.0;
  static const double displaySmall = 24.0;
  static const double headlineLarge = 22.0;
  static const double headlineMedium = 20.0;
  static const double titleLarge = 18.0;
  static const double titleMedium = 16.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double labelLarge = 14.0;

  // Line heights (multipliers)
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // Letter spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 1.0;
  static const double letterSpacingWider = 1.5;
}
