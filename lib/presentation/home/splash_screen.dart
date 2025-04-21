import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/config/app_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Add a small delay to show the splash screen
    await Future.delayed(const Duration(seconds: 1));

    final bool isAuthenticated = await AuthService.isAuthenticated();

    if (mounted) {
      if (isAuthenticated) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.homePage);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.loginPage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FlutterLogo(size: 100),
            SizedBox(height: 24),
            Text(
              App.appName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
