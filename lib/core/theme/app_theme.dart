import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Generates a [ThemeData] from a seed color and brightness.
/// Pass any [Color] as [seedColor] to re-skin the entire app.
class AppTheme {
  AppTheme._();

  static ThemeData light({Color seedColor = AppColors.brandPrimary}) {
    final cs = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      primary: seedColor,
      secondary: AppColors.brandSecondary,
      error: AppColors.error,
      surface: AppColors.surfaceLight,
    );
    return _build(cs);
  }

  static ThemeData dark({Color seedColor = AppColors.brandPrimary}) {
    final cs = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      primary: seedColor,
      secondary: AppColors.brandSecondary,
      error: AppColors.error,
      surface: AppColors.surfaceDark,
    );
    return _build(cs);
  }

  static ThemeData _build(ColorScheme cs) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: cs.brightness == Brightness.light
          ? AppColors.backgroundLight
          : AppColors.backgroundDark,
    );

    return base.copyWith(
      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:
            cs.brightness == Brightness.light ? AppColors.surfaceLight : AppColors.surfaceDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: cs.onSurface,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      // ── Card ──────────────────────────────────────────────────────────
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cs.brightness == Brightness.light
            ? AppColors.surfaceLight
            : AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
      ),
      // ── Input ─────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.brightness == Brightness.light
            ? AppColors.neutral100
            : AppColors.neutral800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      // ── ElevatedButton ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
        ),
      ),
      // ── OutlinedButton ────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      // ── Chip ──────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(space: 1, thickness: 1),
      // ── ListTile ──────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}
