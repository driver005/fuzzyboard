import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool isAuthenticated = false;
  String? currentUserEmail;
  String? currentUserName;
  bool isLoading = true;

  static const String keyEmail = 'auth_email';
  static const String keyName = 'auth_name';
  static const String keyIsAuthenticated = 'auth_is_authenticated';

  AuthProvider() {
    loadAuth();
  }

  Future<void> loadAuth() async {
    final prefs = await SharedPreferences.getInstance();
    isAuthenticated = prefs.getBool(keyIsAuthenticated) ?? false;
    currentUserEmail = prefs.getString(keyEmail);
    currentUserName = prefs.getString(keyName);
    isLoading = false;
    notifyListeners();
  }

  static const emailRegex =
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$';

  Future<String?> signup(String name, String email, String password) async {
    if (name.trim().isEmpty) return 'Name is required';
    if (email.trim().isEmpty) return 'Email is required';
    if (!RegExp(emailRegex).hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }
    if (password.length < 6) return 'Password must be at least 6 characters';

    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    isAuthenticated = true;
    currentUserEmail = email.trim();
    currentUserName = name.trim();
    await prefs.setBool(keyIsAuthenticated, true);
    await prefs.setString(keyEmail, email.trim());
    await prefs.setString(keyName, name.trim());

    isLoading = false;
    notifyListeners();
    return null;
  }

  /// Signs in the user with the given credentials.
  /// NOTE: This is a local demo implementation — no backend validation is
  /// performed. In production, credentials should be verified server-side.
  Future<String?> login(String email, String password) async {
    if (email.trim().isEmpty) return 'Email is required';
    if (!RegExp(emailRegex).hasMatch(email.trim())) {
      return 'Please enter a valid email address';
    }
    if (password.isEmpty) return 'Password is required';

    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    isAuthenticated = true;
    currentUserEmail = email.trim();
    currentUserName = email.trim().split('@').first;
    await prefs.setBool(keyIsAuthenticated, true);
    await prefs.setString(keyEmail, email.trim());
    await prefs.setString(keyName, currentUserName!);

    isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    isAuthenticated = false;
    currentUserEmail = null;
    currentUserName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyEmail);
    await prefs.remove(keyName);
    await prefs.remove(keyIsAuthenticated);
    notifyListeners();
  }
}
