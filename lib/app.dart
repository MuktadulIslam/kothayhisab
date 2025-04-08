import 'package:flutter/material.dart';
import 'package:kothayhisab/config/routes.dart';
import 'package:kothayhisab/config/themes.dart';

class KothayHisabApp extends StatelessWidget {
  const KothayHisabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Page Navigation',
      theme: AppTheme.appTheme,
      // Define the routes for navigation
      routes: appRoutes,
      initialRoute: '/home',
    );
  }
}
