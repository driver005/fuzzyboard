import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';

/// Manages theme mode (light/dark/system) and seed color.
/// Uses SharedPreferences to persist across restarts.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  Color _seedColor = AppColors.brandPrimary;
  bool _compactSidebar = false;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  bool get compactSidebar => _compactSidebar;

  ThemeData get lightTheme => AppTheme.light(seedColor: _seedColor);
  ThemeData get darkTheme => AppTheme.dark(seedColor: _seedColor);

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('themeMode') ?? 2; // 2 = dark
    final colorValue = prefs.getInt('seedColor');
    _themeMode = ThemeMode.values[modeIndex];
    if (colorValue != null) {
      // Reconstruct color from stored ARGB int
      _seedColor = Color(colorValue);
    }
    _compactSidebar = prefs.getBool('compactSidebar') ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // Store as ARGB integer (color.value returns the ARGB int representation)
    // ignore: deprecated_member_use
    await prefs.setInt('seedColor', color.value);
  }

  Future<void> setCompactSidebar(bool v) async {
    _compactSidebar = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('compactSidebar', v);
  }
}
