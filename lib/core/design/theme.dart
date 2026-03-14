import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

/// Matte Black Dark-Only Theme
class ModernTheme {
  static ThemeData dark() {
    const cs = ColorScheme.dark(
      primary:                AppPalette.accent,
      onPrimary:              Color(0xFF0A0A0A),
      primaryContainer:       AppPalette.accentMuted,
      onPrimaryContainer:     AppPalette.accent,
      secondary:              AppPalette.success,
      onSecondary:            Color(0xFF0A0A0A),
      error:                  AppPalette.error,
      onError:                Color(0xFF0A0A0A),
      surface:                AppPalette.surface,
      onSurface:              AppPalette.text,
      onSurfaceVariant:       AppPalette.textSec,
      surfaceContainerHighest: AppPalette.surfaceTop,
      outline:                AppPalette.border,
      outlineVariant:         AppPalette.borderLight,
      shadow:                 Colors.black,
      scrim:                  Colors.black87,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: AppPalette.bg,
      fontFamily: AppText.fontFamily,

      // AppBar — transparent, borderless
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppPalette.bg,
        foregroundColor: AppPalette.text,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppPalette.surface,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: AppText.h2.copyWith(color: AppPalette.text),
        iconTheme: const IconThemeData(color: AppPalette.text, size: 22),
      ),

      // Card — flat matte surface with border
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppPalette.border, width: 1),
        ),
        color: AppPalette.surface,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated Button — accent solid
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppPalette.accent,
          foregroundColor: Colors.black,
          disabledBackgroundColor: AppPalette.surfaceHigh,
          disabledForegroundColor: AppPalette.textTert,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppText.button,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        ),
      ),

      // Outlined Button — bordered
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.text,
          side: const BorderSide(color: AppPalette.border, width: 1),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: AppText.button,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppPalette.accent,
          textStyle: AppText.buttonSm,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 8),
        ),
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.surfaceTop,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppPalette.error, width: 1.5),
        ),
        hintStyle: AppText.bodyMd.copyWith(color: AppPalette.textTert),
        labelStyle: AppText.labelLg.copyWith(color: AppPalette.textSec),
        errorStyle: AppText.bodySm.copyWith(color: AppPalette.error),
      ),

      // Bottom Nav — custom handled in AppShell
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppPalette.surface,
        indicatorColor: AppPalette.accentMuted,
        labelTextStyle: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
            ? AppText.labelSm.copyWith(color: AppPalette.accent)
            : AppText.labelSm.copyWith(color: AppPalette.textTert),
        ),
        iconTheme: WidgetStateProperty.resolveWith((s) =>
          IconThemeData(
            color: s.contains(WidgetState.selected) ? AppPalette.accent : AppPalette.textTert,
            size: 22,
          ),
        ),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppPalette.border,
        thickness: 1,
        space: 1,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppPalette.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        titleTextStyle: AppText.h2.copyWith(color: AppPalette.text),
        contentTextStyle: AppText.bodyMd.copyWith(color: AppPalette.textSec),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppPalette.surfaceHigh,
        contentTextStyle: AppText.bodyMd.copyWith(color: AppPalette.text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppPalette.border),
        ),
        elevation: 0,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppPalette.surfaceHigh,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppPalette.surfaceTop,
        deleteIconColor: AppPalette.textSec,
        labelStyle: AppText.labelMd.copyWith(color: AppPalette.textSec),
        side: const BorderSide(color: AppPalette.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),

      // Icon
      iconTheme: const IconThemeData(color: AppPalette.textSec, size: 22),
    );
  }

  // Keep light stub for compat — always returns dark
  static ThemeData light() => dark();
}
