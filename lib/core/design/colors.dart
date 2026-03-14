import 'package:flutter/material.dart';

/// Matte Black Dark-Only Palette
class AppPalette {
  // === BACKGROUND HIERARCHY ===
  static const Color bg          = Color(0xFF0A0A0A); // Scaffold
  static const Color surface     = Color(0xFF141414); // Card
  static const Color surfaceHigh = Color(0xFF1C1C1C); // Elevated card
  static const Color surfaceTop  = Color(0xFF242424); // Input fill / chip

  // === BORDERS ===
  static const Color border      = Color(0xFF252525);
  static const Color borderLight = Color(0xFF2E2E2E);

  // === TEXT ===
  static const Color text        = Color(0xFFF2F2F2); // Primary
  static const Color textSec     = Color(0xFF808080); // Secondary
  static const Color textTert    = Color(0xFF4A4A4A); // Hint / placeholder

  // === ACCENT ===
  static const Color accent      = Color(0xFFFF6B2B); // Warm amber-orange CTA
  static const Color accentDark  = Color(0xFFD9511B); // Pressed accent
  static const Color accentMuted = Color(0x1AFF6B2B); // 10% accent bg

  // === SEMANTIC ===
  static const Color success     = Color(0xFF22C55E);
  static const Color successMuted = Color(0x1A22C55E);
  static const Color warning     = Color(0xFFF59E0B);
  static const Color warningMuted = Color(0x1AF59E0B);
  static const Color error       = Color(0xFFEF4444);
  static const Color errorMuted  = Color(0x1AEF4444);
  static const Color info        = Color(0xFF38BDF8);
  static const Color infoMuted   = Color(0x1A38BDF8);

  // === MACROS ===
  static const Color protein     = Color(0xFFF472B6);
  static const Color carbs       = Color(0xFF60A5FA);
  static const Color fat         = Color(0xFFFBBF24);
  static const Color water       = Color(0xFF38BDF8);

  // === MEAL CATEGORIES ===
  static const Color breakfast   = Color(0xFFFFB74D);
  static const Color lunch       = Color(0xFF4CAF50);
  static const Color dinner      = Color(0xFF42A5F5);
  static const Color snack       = Color(0xFFAB47BC);

  // === LEGACY COMPAT (for old references) ===
  static const Color primary            = accent;
  static const Color primaryLight       = Color(0xFFFF9162);
  static const Color primaryDark        = accentDark;
  static const Color darkBackground     = bg;
  static const Color darkSurface        = surface;
  static const Color darkSurfaceVariant = surfaceTop;
  static const Color darkText           = text;
  static const Color darkTextSecondary  = textSec;
  static const Color darkBorder         = border;
  static const Color lightBackground    = bg;
  static const Color lightSurface       = surface;
  static const Color lightSurfaceVariant = surfaceTop;
  static const Color lightText          = text;
  static const Color lightTextSecondary = textSec;
  static const Color lightBorder        = border;
  static const Color neutral50   = Color(0xFFF9F9F9);
  static const Color neutral100  = Color(0xFFF3F3F3);
  static const Color neutral200  = Color(0xFFE8E8E8);
  static const Color neutral300  = Color(0xFFD1D1D1);
  static const Color neutral400  = Color(0xFF9E9E9E);
  static const Color neutral500  = Color(0xFF6B6B6B);
  static const Color neutral600  = Color(0xFF4A4A4A);
  static const Color neutral700  = Color(0xFF333333);
  static const Color neutral800  = Color(0xFF1E1E1E);
  static const Color neutral900  = Color(0xFF0A0A0A);
}
