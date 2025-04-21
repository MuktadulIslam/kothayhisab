import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';
import 'package:kothayhisab/data/api/services/auth_service.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final bool authRequired;

  const AuthGuard({super.key, required this.child, this.authRequired = true});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isAuthenticated = snapshot.data ?? false;

        if (authRequired && !isAuthenticated) {
          // Redirect to login page if authentication is required but user is not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.loginPage, (route) => false);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (!authRequired && isAuthenticated) {
          // Redirect to home page if user is already authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.loginPage, (route) => false);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return child;
      },
    );
  }
}
