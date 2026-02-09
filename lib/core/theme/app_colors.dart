import 'package:flutter/material.dart';

/// Complete design system colors for CalorieWala
/// Based on Material Design 3 with food-centric customization
class AppColors {
  // === PRIMARY PALETTE ===
  // Warm, appetizing orange-red (Food photography friendly)
  static const Color primary = Color(0xFFFF6B35); // Vibrant Coral
  static const Color primaryDark = Color(0xFFE85A2C);
  static const Color primaryLight = Color(0xFFFF9671);
  static const Color onPrimary = Colors.white;

  // === SECONDARY PALETTE ===
  // Fresh, healthy green
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF81C784);
  static const Color onSecondary = Colors.white;

  // === NUTRITION COLORS ===
  static const Color protein = Color(0xFFE91E63); // Pink
  static const Color carbs = Color(0xFFFFA726); // Orange
  static const Color fat = Color(0xFF42A5F5); // Blue
  static const Color fiber = Color(0xFF66BB6A); // Green

  // === SEMANTIC COLORS ===
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // === NEUTRAL COLORS ===
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFAFAFA);

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFFBDBDBD);

  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color divider = Color(0xFFBDBDBD);

  // === DARK MODE ===
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A);
  static const Color darkText = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkTextTertiary = Color(0xFF707070);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkDivider = Color(0xFF2A2A2A);

  // Dark mode nutrition colors (slightly desaturated)
  static const Color darkProtein = Color(0xFFFF4081);
  static const Color darkCarbs = Color(0xFFFFB74D);
  static const Color darkFat = Color(0xFF64B5F6);

  // === LEGACY SUPPORT (Backward compatibility) ===
  static const Color accent = secondary;
  static const Color accentLight = secondaryLight;
  static const Color accentDark = secondaryDark;
  static const Color lightBackground = background;
  static const Color lightSurface = surface;
  static const Color lightText = textPrimary;
  static const Color lightTextSecondary = textSecondary;
  static const Color lightBorder = border;

  // === GRADIENTS ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = secondaryGradient;

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFAFAFA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // === SHADOWS ===
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // === OVERLAYS ===
  static Color get overlay => Colors.black.withOpacity(0.5);
  static Color get shimmer => Colors.white.withOpacity(0.3);
  static Color get scrim => Colors.black.withOpacity(0.32);
}
