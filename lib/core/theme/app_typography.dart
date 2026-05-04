import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// All text styles for FuzzyBoard.
/// Nunito is a rounded, friendly typeface that gives the app a game-like feel.
/// Swap `GoogleFonts.nunitoTextTheme(...)` for any other Google Font call to
/// instantly change the app-wide typography.
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => GoogleFonts.nunitoTextTheme(
        const TextTheme(
          displayLarge:  TextStyle(fontSize: 57, fontWeight: FontWeight.w800),
          displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w800),
          displaySmall:  TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
          headlineLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          headlineSmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          titleLarge:  TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          titleSmall:  TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          bodyLarge:   TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          bodyMedium:  TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          bodySmall:   TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          labelLarge:  TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          labelSmall:  TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      );

  /// Monospace style for code editors / dev mode
  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 13,
    height: 1.6,
  );
}
