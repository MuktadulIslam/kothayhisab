import 'package:flutter/material.dart';
import 'package:kothayhisab/config/routes.dart';
import 'package:kothayhisab/auth_guard.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';
import 'package:kothayhisab/config/themes.dart';
import 'package:kothayhisab/presentation/home/splash_screen.dart';

class KothayHisabApp extends StatelessWidget {
  const KothayHisabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Page Navigation',
      theme: AppTheme.appTheme,
      onGenerateRoute: (settings) {
        // Allow splash screen to be accessed without auth check
        if (settings.name == AppRoutes.splashPage) {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => const SplashScreen(),
          );
        }

        // Get the route definition from your routes map
        final builder = appRoutes[settings.name];
        if (builder == null) return null;

        // Check if the route requires authentication
        final requiresAuth = !nonAuthRoutes.contains(settings.name);

        return MaterialPageRoute(
          settings: settings,
          builder:
              (context) => AuthGuard(
                authRequired: requiresAuth,
                child: builder(context),
              ),
        );
      },
      initialRoute:
          AppRoutes.splashPage, // Change initial route to splash screen
    );
  }
}
