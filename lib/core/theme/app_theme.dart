import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Generates a [ThemeData] from a seed color and brightness.
/// All structural values (radii, shadows, border widths) are read from the
/// token classes in [AppColors], [AppRadius], [AppBorderWidth], and [AppGlow]
/// so the entire app can be re-skinned from one file.
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
        backgroundColor: isLight ? AppColors.headerLight : AppColors.headerDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: cs.onSurface,
        ),
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      // ── Card ──────────────────────────────────────────────────────────
      cardTheme: CardTheme(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: isLight ? AppColors.cardBorderLight : AppColors.cardBorderDark,
            width: AppBorderWidth.thin,
          ),
        ),
        color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
        surfaceTintColor: Colors.transparent,
      ),
      // ── Input ─────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.neutral100 : AppColors.neutral800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: AppColors.borderDefault(isLight ? false : true),
            width: AppBorderWidth.thin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: cs.primary, width: AppBorderWidth.thick),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      // ── ElevatedButton ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
        ),
      ),
      // ── OutlinedButton ────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary, width: AppBorderWidth.normal),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      // ── Chip ──────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        side: BorderSide(
          color: AppColors.borderDefault(!isLight),
          width: AppBorderWidth.thin,
        ),
      ),
      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        space: 1,
        thickness: 1,
        color: AppColors.borderSubtle(!isLight),
      ),
      // ── ListTile ──────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
      ),
    );
  }
}
