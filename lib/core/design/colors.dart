import 'package:flutter/material.dart';

/// Modern, Professional Color System
/// Neutral-first with subtle accents
class AppPalette {
  // === NEUTRAL SCALE (Primary) ===
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // === PRIMARY (Subtle Orange) ===
  static const Color primary = Color(0xFFFF7043); // Softer coral
  static const Color primaryLight = Color(0xFFFF9E7A);
  static const Color primaryDark = Color(0xFFE6502B);

  // === SEMANTIC ===
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // === NUTRITION (Muted) ===
  static const Color protein = Color(0xFFEC407A);
  static const Color carbs = Color(0xFFFFB74D);
  static const Color fat = Color(0xFF42A5F5);

  // === LIGHT THEME ===
  static const Color lightBackground = neutral50;
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = neutral100;
  static const Color lightText = neutral900;
  static const Color lightTextSecondary = neutral600;
  static const Color lightBorder = neutral200;

  // === DARK THEME ===
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);
  static const Color darkBorder = Color(0xFF373737);
}
