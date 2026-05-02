import 'package:flutter/material.dart';

enum UserRole { admin, user }

class UserProvider extends ChangeNotifier {
  UserRole currentRole = UserRole.admin;

  bool get isAdmin => currentRole == UserRole.admin;

  void switchRole(UserRole role) {
    if (currentRole == role) return;
    currentRole = role;
    notifyListeners();
  }
}
