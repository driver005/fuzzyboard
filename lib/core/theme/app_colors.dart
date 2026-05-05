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
  static const Color brandPrimary   = Color(0xFF7B2FFF); // electric violet
  /// Secondary brand colour — used for accents, progress, success states.
  static const Color brandSecondary = Color(0xFF00FFD1); // neon teal
  /// Accent colour — used for badges, danger, special call-to-actions.
  static const Color brandAccent    = Color(0xFFFF0080); // hot magenta

  // ── Extended neon palette ─────────────────────────────────────────────────
  static const Color neonCyan   = Color(0xFF00E5FF);
  static const Color neonYellow = Color(0xFFFFD600);
  static const Color neonOrange = Color(0xFFFF6B00);
  static const Color neonGreen  = Color(0xFF39FF14);
  static const Color neonBlue   = Color(0xFF00A8FF);
  static const Color neonPink   = Color(0xFFFF0080);
  static const Color gold       = Color(0xFFEAB308);

  // ── Neutral palette (violet-tinted greys) ─────────────────────────────────
  static const Color neutral50  = Color(0xFFF3F0FF);
  static const Color neutral100 = Color(0xFFE9E4FF);
  static const Color neutral200 = Color(0xFFD4CBFF);
  static const Color neutral300 = Color(0xFFB8ABFF);
  static const Color neutral400 = Color(0xFF9A88FF);
  static const Color neutral500 = Color(0xFF7B65FF);
  static const Color neutral600 = Color(0xFF6347D9);
  static const Color neutral700 = Color(0xFF4A31B3);
  static const Color neutral800 = Color(0xFF2A1880);
  static const Color neutral900 = Color(0xFF100A40);

  // ── Semantic colours ──────────────────────────────────────────────────────
  static const Color success = Color(0xFF00FFD1);
  static const Color warning = Color(0xFFFFD600);
  static const Color error   = Color(0xFFFF0080);
  static const Color info    = Color(0xFF00E5FF);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  /// Very deep navy — the "night city" canvas behind all surfaces.
  static const Color backgroundDark  = Color(0xFF070912);
  static const Color backgroundLight = Color(0xFFF0F2FF); // cool off-white

  // ── Surfaces (cards / dialogs / sheets) ──────────────────────────────────
  static const Color surfaceLight = Color(0xFFFFFFFF);
  /// Slightly lighter than the background so cards visibly "float".
  static const Color surfaceDark  = Color(0xFF0E1220);

  // ── Sidebar ───────────────────────────────────────────────────────────────
  static const Color sidebarLight = Color(0xFFFFFFFF);
  /// Darker than surfaceDark — creates a subtle depth contrast.
  static const Color sidebarDark  = Color(0xFF090C18);

  // ── Header ────────────────────────────────────────────────────────────────
  static const Color headerLight = Color(0xFFFFFFFF);
  static const Color headerDark  = Color(0xFF0B0E1C);

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
