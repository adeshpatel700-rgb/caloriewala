import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter-based Typography System
class AppText {
  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        height: height ?? 1.4,
        letterSpacing: letterSpacing,
        color: color,
      );

  // === DISPLAY ===
  static TextStyle get displayLg => _base(size: 36, weight: FontWeight.w700, height: 1.1, letterSpacing: -0.5);
  static TextStyle get displayMd => _base(size: 30, weight: FontWeight.w700, height: 1.15, letterSpacing: -0.3);
  static TextStyle get displaySm => _base(size: 24, weight: FontWeight.w700, height: 1.2, letterSpacing: -0.2);

  // === HEADINGS ===
  static TextStyle get h1 => _base(size: 22, weight: FontWeight.w700, height: 1.3, letterSpacing: -0.15);
  static TextStyle get h2 => _base(size: 18, weight: FontWeight.w600, height: 1.35);
  static TextStyle get h3 => _base(size: 16, weight: FontWeight.w600, height: 1.4);
  static TextStyle get h4 => _base(size: 14, weight: FontWeight.w600, height: 1.4);

  // === BODY ===
  static TextStyle get bodyLg  => _base(size: 15, weight: FontWeight.w400, height: 1.55);
  static TextStyle get bodyMd  => _base(size: 14, weight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySm  => _base(size: 13, weight: FontWeight.w400, height: 1.45);
  static TextStyle get bodyXs  => _base(size: 12, weight: FontWeight.w400, height: 1.4);

  // === LABEL ===
  static TextStyle get labelLg => _base(size: 13, weight: FontWeight.w500, height: 1.3, letterSpacing: 0.1);
  static TextStyle get labelMd => _base(size: 12, weight: FontWeight.w500, height: 1.3, letterSpacing: 0.15);
  static TextStyle get labelSm => _base(size: 11, weight: FontWeight.w500, height: 1.2, letterSpacing: 0.3);
  static TextStyle get labelXs => _base(size: 10, weight: FontWeight.w600, height: 1.2, letterSpacing: 0.5);

  // === BUTTON ===
  static TextStyle get button  => _base(size: 15, weight: FontWeight.w600, height: 1.2, letterSpacing: 0.1);
  static TextStyle get buttonSm => _base(size: 13, weight: FontWeight.w600, height: 1.2, letterSpacing: 0.1);

  // === MONO (numbers) ===
  static TextStyle get number  => GoogleFonts.spaceGrotesk(
        fontSize: 16, fontWeight: FontWeight.w700, height: 1.2,
      );
  static TextStyle get numberLg => GoogleFonts.spaceGrotesk(
        fontSize: 48, fontWeight: FontWeight.w800, height: 1.0, letterSpacing: -1,
      );
  static TextStyle get numberMd => GoogleFonts.spaceGrotesk(
        fontSize: 28, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -0.5,
      );
  static TextStyle get numberSm => GoogleFonts.spaceGrotesk(
        fontSize: 18, fontWeight: FontWeight.w700, height: 1.2,
      );

  // === LEGACY COMPAT ===
  static TextStyle get headingLarge  => h1;
  static TextStyle get headingMedium => h2;
  static TextStyle get headingSmall  => h3;
  static TextStyle get bodyLarge     => bodyLg;
  static TextStyle get bodyMedium    => bodyMd;
  static TextStyle get bodySmall     => bodySm;
  static TextStyle get labelLarge    => labelLg;
  static TextStyle get labelMedium   => labelMd;
  static TextStyle get labelSmall    => labelSm;
  static TextStyle get displayLarge  => displayLg;
  static TextStyle get displayMedium => displayMd;
  static TextStyle get displaySmall  => displaySm;
}
