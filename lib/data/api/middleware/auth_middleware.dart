import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/auth_service.dart';

class AuthMiddleware {
  // Navigate to login if user is not authenticated
  static Future<bool> checkAuth(BuildContext context) async {
    final bool isAuthenticated = await AuthService.isAuthenticated();

    if (!isAuthenticated) {
      // Delay the navigation to avoid build phase conflicts
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed('/login');
      });
      return false;
    }

    return true;
  }

  // Navigate to home if user is already authenticated
  static Future<bool> checkAlreadyLoggedIn(BuildContext context) async {
    final bool isAuthenticated = await AuthService.isAuthenticated();

    if (isAuthenticated) {
      // Delay the navigation to avoid build phase conflicts
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed('/home');
      });
      return false;
    }

    return true;
  }
}
