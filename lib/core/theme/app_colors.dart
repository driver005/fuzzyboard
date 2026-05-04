import 'package:flutter/material.dart';

/// Centralized color palette for FuzzyBoard.
/// Change the seed color here to instantly re-skin the whole app.
class AppColors {
  AppColors._();

  // ── Brand seeds – vivid, game-feel ────────────────────────────────────────
  static const Color brandPrimary   = Color(0xFF7C3AED); // electric violet
  static const Color brandSecondary = Color(0xFF06D6A0); // neon mint
  static const Color brandAccent    = Color(0xFFFF3D71); // hot pink

  // ── Game accent palette ───────────────────────────────────────────────────
  static const Color neonCyan   = Color(0xFF00E5FF);
  static const Color neonYellow = Color(0xFFFFD600);
  static const Color neonOrange = Color(0xFFFF6B00);
  static const Color gold       = Color(0xFFEAB308);

  // ── Neutral palette ───────────────────────────────────────────────────────
  static const Color neutral50  = Color(0xFFF5F3FF); // slight violet tint
  static const Color neutral100 = Color(0xFFEDE9FE);
  static const Color neutral200 = Color(0xFFDDD6FE);
  static const Color neutral300 = Color(0xFFC4B5FD);
  static const Color neutral400 = Color(0xFFA78BFA);
  static const Color neutral500 = Color(0xFF8B5CF6);
  static const Color neutral600 = Color(0xFF7C3AED);
  static const Color neutral700 = Color(0xFF6D28D9);
  static const Color neutral800 = Color(0xFF4C1D95);
  static const Color neutral900 = Color(0xFF2E1065);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFD600);
  static const Color error   = Color(0xFFFF3D71);
  static const Color info    = Color(0xFF00E5FF);

  // ── Surface overrides per theme ───────────────────────────────────────────
  static const Color surfaceLight     = Color(0xFFFFFFFF);
  static const Color surfaceDark      = Color(0xFF1A1035);
  static const Color backgroundLight  = Color(0xFFF0EEFF); // soft lavender bg
  static const Color backgroundDark   = Color(0xFF0F0B20);
  static const Color sidebarLight     = Color(0xFFFFFFFF);
  static const Color sidebarDark      = Color(0xFF130E2B);
}
