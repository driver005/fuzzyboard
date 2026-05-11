import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════════════
// FUZZYBOARD MASTER DESIGN TOKEN FILE
//
// Every visual property — colour, radius, border width, shadow — lives here.
// Change a value in this file and the entire app re-skins automatically.
//
// • AppColors      — all colour tokens
// • AppRadius      — border-radius constants
// • AppBorderWidth — border-thickness constants
// • AppGlow        — pre-built BoxShadow lists (neon / card / button)
// ════════════════════════════════════════════════════════════════════════════

// ── Colour tokens ─────────────────────────────────────────────────────────────

/// All colour constants for FuzzyBoard.
/// Swap just the three *brand* colours to completely re-theme the app.
class AppColors {
  AppColors._();

  // ── Brand palette (change these 3 to re-skin the whole app) ──────────────
  /// Primary brand colour — used for interactive highlights, active states.
  static const Color brandPrimary   = Color(0xFF3B82F6); // smart home blue
  /// Secondary brand colour — used for accents, progress, success states.
  static const Color brandSecondary = Color(0xFF22D3EE); // cool cyan
  /// Accent colour — used for badges, danger, special call-to-actions.
  static const Color brandAccent    = Color(0xFFF59E0B); // warm amber

  // ── Extended neon palette ─────────────────────────────────────────────────
  static const Color neonCyan   = Color(0xFF22D3EE);
  static const Color neonYellow = Color(0xFFEAB308);
  static const Color neonOrange = Color(0xFFF59E0B);
  static const Color neonGreen  = Color(0xFF22C55E);
  static const Color neonBlue   = Color(0xFF3B82F6);
  static const Color neonPink   = Color(0xFFEC4899);
  static const Color gold       = Color(0xFFEAB308);

  // ── Neutral palette (blue-tinted greys) ──────────────────────────────────
  static const Color neutral50  = Color(0xFFEFF6FF);
  static const Color neutral100 = Color(0xFFDBEAFE);
  static const Color neutral200 = Color(0xFFBFDBFE);
  static const Color neutral300 = Color(0xFF93C5FD);
  static const Color neutral400 = Color(0xFF60A5FA);
  static const Color neutral500 = Color(0xFF3B82F6);
  static const Color neutral600 = Color(0xFF2563EB);
  static const Color neutral700 = Color(0xFF1D4ED8);
  static const Color neutral800 = Color(0xFF1E3A8A);
  static const Color neutral900 = Color(0xFF0F1F4A);

  // ── Semantic colours ──────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF22D3EE);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  /// Very deep navy — the "smart home night" canvas behind all surfaces.
  static const Color backgroundDark  = Color(0xFF060B18);
  static const Color backgroundLight = Color(0xFFF0F7FF); // cool off-white

  // ── Surfaces (cards / dialogs / sheets) ──────────────────────────────────
  static const Color surfaceLight = Color(0xFFFFFFFF);
  /// Slightly lighter than the background so cards visibly "float".
  static const Color surfaceDark  = Color(0xFF0C1428);

  // ── Sidebar ───────────────────────────────────────────────────────────────
  static const Color sidebarLight = Color(0xFFFFFFFF);
  /// Darker than surfaceDark — creates a subtle depth contrast.
  static const Color sidebarDark  = Color(0xFF080E20);

  // ── Header ────────────────────────────────────────────────────────────────
  static const Color headerLight = Color(0xFFFFFFFF);
  static const Color headerDark  = Color(0xFF0A1228);

  // ── Border helper colours ─────────────────────────────────────────────────
  /// Barely-visible structural divider.
  static Color borderSubtle(bool isDark) =>
      isDark ? const Color(0x14FFFFFF) : const Color(0x10000000);

  /// Mid-strength border for cards / inputs.
  static Color borderDefault(bool isDark) =>
      isDark ? const Color(0x22FFFFFF) : const Color(0x18000000);

  /// Vivid accent border (uses primary colour at this opacity).
  static const double borderAccentOpacity = 0.45;

  /// Dark-mode card outline — subtle neon tint.
  static final Color cardBorderDark  = brandPrimary.withOpacity(0.18);
  static const Color cardBorderLight = Color(0x12000000);
}

// ── Border-radius tokens ──────────────────────────────────────────────────────

/// All border-radius values for FuzzyBoard.
/// Changing a constant here updates every widget that uses it.
class AppRadius {
  AppRadius._();

  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;

  /// Cards, dialogs, sheets.
  static const double card = 16.0;

  /// Pill-shaped buttons / badges.
  static const double pill = 100.0;
}

// ── Border-width tokens ───────────────────────────────────────────────────────

/// Border-stroke thickness constants used across the app.
class AppBorderWidth {
  AppBorderWidth._();

  static const double thin   = 1.0;
  static const double normal = 1.5;
  static const double thick  = 2.0;
}

// ── Glow / shadow presets ─────────────────────────────────────────────────────

/// Pre-built [BoxShadow] lists that embody the neon-city aesthetic.
class AppGlow {
  AppGlow._();

  /// Tight neon glow — great for active / focused elements.
  static List<BoxShadow> neon(Color color, {double radius = 14}) => [
    BoxShadow(
      color: color.withOpacity(0.55),
      blurRadius: radius,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: color.withOpacity(0.22),
      blurRadius: radius * 2.8,
      spreadRadius: -2,
    ),
  ];

  /// Soft ambient shadow for floating cards.
  static List<BoxShadow> card(Color primary) => [
    BoxShadow(
      color: primary.withOpacity(0.10),
      blurRadius: 22,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: primary.withOpacity(0.04),
      blurRadius: 48,
      offset: const Offset(0, 12),
    ),
  ];

  /// Button elevation glow.
  static List<BoxShadow> button(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.52),
      blurRadius: 16,
      offset: const Offset(0, 5),
    ),
  ];
}
