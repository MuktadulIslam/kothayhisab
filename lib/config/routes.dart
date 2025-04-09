// lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:kothayhisab/presentation/auth/login/login_screen.dart';
import 'package:kothayhisab/presentation/auth/register/register_screen.dart';
import 'package:kothayhisab/presentation/home/home_screen.dart';
import 'package:kothayhisab/presentation/home/splash_screen.dart';
import 'package:kothayhisab/presentation/shops/shops_screen.dart';
import 'package:kothayhisab/presentation/store/store_screen.dart';
import 'package:kothayhisab/presentation/sell/sell_screen.dart';
import 'package:kothayhisab/presentation/report/monthly_report.dart';
import 'package:kothayhisab/presentation/settings/settings_screen.dart';
import 'package:kothayhisab/presentation/profile/profile_screen.dart';
import 'package:kothayhisab/presentation/help/help_screen.dart';
import 'package:kothayhisab/presentation/shops/show_all_shops.dart';
import 'package:kothayhisab/presentation/shops/add_new_shop.dart';

// Define the routes for navigation
final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/shops': (context) => const ShopsScreen(),
  '/monthlyReport': (context) => const MonthlyReportScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/settings': (context) => const SettingsScreen(),
  '/help': (context) => const HelpScreen(),
  '/home': (context) => const SplashScreen(),
  '/store': (context) => const StoreScreen(),
  '/sell': (context) => const SellScreen(),
  '/store/show_all_shops': (context) => const ShopViewScreen(),
  '/store/add_shops': (context) => const AddNewShopScreen(),
  // '/store/show_products': (context) => const StoredProductsPage(),
  // '/store/add_products': (context) => const AddNewProdectsPage(),
};
