import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool isAuthenticated = false;
  String? currentUserEmail;
  String? currentUserName;
  bool isLoading = true;

  static const String _keyEmail = 'auth_email';
  static const String _keyName = 'auth_name';
  static const String _keyIsAuthenticated = 'auth_is_authenticated';

  AuthProvider() {
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    isAuthenticated = prefs.getBool(_keyIsAuthenticated) ?? false;
    currentUserEmail = prefs.getString(_keyEmail);
    currentUserName = prefs.getString(_keyName);
    isLoading = false;
    notifyListeners();
  }

  Future<String?> signup(String name, String email, String password) async {
    if (name.trim().isEmpty) return 'Name is required';
    if (email.trim().isEmpty) return 'Email is required';
    if (password.length < 6) return 'Password must be at least 6 characters';

    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    isAuthenticated = true;
    currentUserEmail = email.trim();
    currentUserName = name.trim();
    await prefs.setBool(_keyIsAuthenticated, true);
    await prefs.setString(_keyEmail, email.trim());
    await prefs.setString(_keyName, name.trim());

    isLoading = false;
    notifyListeners();
    return null;
  }

  Future<String?> login(String email, String password) async {
    if (email.trim().isEmpty) return 'Email is required';
    if (password.isEmpty) return 'Password is required';

    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    isAuthenticated = true;
    currentUserEmail = email.trim();
    currentUserName = email.trim().split('@').first;
    await prefs.setBool(_keyIsAuthenticated, true);
    await prefs.setString(_keyEmail, email.trim());
    await prefs.setString(_keyName, currentUserName!);

    isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    isAuthenticated = false;
    currentUserEmail = null;
    currentUserName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyName);
    await prefs.remove(_keyIsAuthenticated);
    notifyListeners();
  }
}
