import 'package:flutter/material.dart';

/// Centralized color palette for FuzzyBoard.
/// Change the seed color here to instantly re-skin the whole app.
class AppColors {
  AppColors._();

  // ── Brand seeds ───────────────────────────────────────────────────────────
  static const Color brandPrimary = Color(0xFF6C63FF);
  static const Color brandSecondary = Color(0xFF00BFA5);
  static const Color brandAccent = Color(0xFFFF6584);

  // ── Neutral palette ───────────────────────────────────────────────────────
  static const Color neutral50 = Color(0xFFFAFAFB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Surface overrides per theme ───────────────────────────────────────────
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E2E);
  static const Color backgroundLight = Color(0xFFF3F4F6);
  static const Color backgroundDark = Color(0xFF13131F);
  static const Color sidebarLight = Color(0xFFFFFFFF);
  static const Color sidebarDark = Color(0xFF16162A);
}
