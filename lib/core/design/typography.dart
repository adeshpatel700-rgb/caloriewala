import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography System using Inter font
class AppText {
  // Base font family
  static TextStyle get _baseStyle => GoogleFonts.inter(
        letterSpacing: -0.01,
        height: 1.4,
      );

  // === DISPLAY (Hero text) ===
  static TextStyle get displayLarge => _baseStyle.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.02,
      );

  static TextStyle get displayMedium => _baseStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.015,
      );

  static TextStyle get displaySmall => _baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  // === HEADING ===
  static TextStyle get headingLarge => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headingMedium => _baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get headingSmall => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // === BODY ===
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  // === LABEL (UI elements) ===
  static TextStyle get labelLarge => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.005,
      );

  static TextStyle get labelMedium => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.01,
      );

  static TextStyle get labelSmall => _baseStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.015,
      );

  // === BUTTON ===
  static TextStyle get button => _baseStyle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: 0.01,
      );
}
