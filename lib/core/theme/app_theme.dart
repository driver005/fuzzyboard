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
    final isLight = cs.brightness == Brightness.light;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor:
          isLight ? AppColors.backgroundLight : AppColors.backgroundDark,
    );

    return base.copyWith(
      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: cs.primary,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: cs.onSurface,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      // ── Card ──────────────────────────────────────────────────────────
      cardTheme: CardTheme(
        elevation: 4,
        shadowColor: cs.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        surfaceTintColor: Colors.transparent,
      ),
      // ── Input ─────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.neutral100 : AppColors.neutral800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.primary, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      // ── ElevatedButton ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 6,
          shadowColor: cs.primary,
        ),
      ),
      // ── OutlinedButton ────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      // ── Chip ──────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),
      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(space: 1, thickness: 1),
      // ── ListTile ──────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
    );
  }
}
