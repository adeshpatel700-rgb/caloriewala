import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

/// Modern, Production-Grade Theme
class ModernTheme {
  /// Light Theme - Clean & Professional
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppPalette.primary,
        onPrimary: AppPalette.lightSurface,
        secondary: AppPalette.success,
        onSecondary: AppPalette.lightSurface,
        error: AppPalette.error,
        onError: AppPalette.lightSurface,
        surface: AppPalette.lightSurface,
        onSurface: AppPalette.lightText,
        surfaceContainerHighest: AppPalette.lightSurfaceVariant,
        outline: AppPalette.lightBorder,
      ),

      scaffoldBackgroundColor: AppPalette.lightBackground,

      // App Bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: AppPalette.lightSurface,
        foregroundColor: AppPalette.lightText,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppText.headingMedium.copyWith(
          color: AppPalette.lightText,
        ),
        iconTheme: const IconThemeData(
          color: AppPalette.lightText,
          size: Spacing.iconSize,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
        ),
        color: AppPalette.lightSurface,
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppPalette.primary,
          foregroundColor: AppPalette.lightSurface,
          disabledBackgroundColor: AppPalette.neutral200,
          disabledForegroundColor: AppPalette.neutral400,
          minimumSize: const Size(double.infinity, Spacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
          ),
          textStyle: AppText.button,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.primary,
          textStyle: AppText.button,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
          ),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.lightSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: const BorderSide(
            color: AppPalette.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: const BorderSide(
            color: AppPalette.error,
            width: 1,
          ),
        ),
        hintStyle: AppText.bodyMedium.copyWith(
          color: AppPalette.neutral400,
        ),
        labelStyle: AppText.bodyMedium.copyWith(
          color: AppPalette.lightTextSecondary,
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: AppPalette.primary,
        foregroundColor: AppPalette.lightSurface,
        shape: CircleBorder(),
      ),

      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppPalette.lightSurface,
        selectedItemColor: AppPalette.primary,
        unselectedItemColor: AppPalette.neutral500,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppText.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppText.labelSmall,
        showUnselectedLabels: true,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppPalette.lightBorder,
        thickness: 1,
        space: 1,
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppPalette.lightText,
        size: Spacing.iconSize,
      ),
    );
  }

  /// Dark Theme - Proper Contrast
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppPalette.primary,
        onPrimary: AppPalette.darkBackground,
        secondary: AppPalette.success,
        onSecondary: AppPalette.darkBackground,
        error: AppPalette.error,
        onError: AppPalette.darkBackground,
        surface: AppPalette.darkSurface,
        onSurface: AppPalette.darkText,
        surfaceContainerHighest: AppPalette.darkSurfaceVariant,
        outline: AppPalette.darkBorder,
      ),

      scaffoldBackgroundColor: AppPalette.darkBackground,

      // App Bar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        backgroundColor: AppPalette.darkSurface,
        foregroundColor: AppPalette.darkText,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppText.headingMedium.copyWith(
          color: AppPalette.darkText,
        ),
        iconTheme: const IconThemeData(
          color: AppPalette.darkText,
          size: Spacing.iconSize,
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
        ),
        color: AppPalette.darkSurface,
        margin: EdgeInsets.zero,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppPalette.primary,
          foregroundColor: AppPalette.darkBackground,
          disabledBackgroundColor: AppPalette.darkBorder,
          disabledForegroundColor: AppPalette.neutral600,
          minimumSize: const Size(double.infinity, Spacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
          ),
          textStyle: AppText.button,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.primary,
          textStyle: AppText.button,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
          ),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: const BorderSide(
            color: AppPalette.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: const BorderSide(
            color: AppPalette.error,
            width: 1,
          ),
        ),
        hintStyle: AppText.bodyMedium.copyWith(
          color: AppPalette.neutral600,
        ),
        labelStyle: AppText.bodyMedium.copyWith(
          color: AppPalette.darkTextSecondary,
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
        backgroundColor: AppPalette.primary,
        foregroundColor: AppPalette.darkBackground,
        shape: CircleBorder(),
      ),

      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: AppPalette.darkSurface,
        selectedItemColor: AppPalette.primary,
        unselectedItemColor: AppPalette.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppText.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppText.labelSmall,
        showUnselectedLabels: true,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppPalette.darkBorder,
        thickness: 1,
        space: 1,
      ),

      // Icon
      iconTheme: const IconThemeData(
        color: AppPalette.darkText,
        size: Spacing.iconSize,
      ),
    );
  }
}
