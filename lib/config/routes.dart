// lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';

import 'package:kothayhisab/presentation/home/home_screen.dart';
import 'package:kothayhisab/presentation/home/splash_screen.dart';
import 'package:kothayhisab/presentation/auth/login/login_screen.dart';
import 'package:kothayhisab/presentation/auth/register/register_screen.dart';
import 'package:kothayhisab/presentation/profile/edit_profile_screen.dart';
import 'package:kothayhisab/presentation/profile/help_screen.dart';
import 'package:kothayhisab/presentation/profile/profile_screen.dart';
import 'package:kothayhisab/presentation/profile/settings_screen.dart';
import 'package:kothayhisab/presentation/sales/add_sales_screen.dart';
import 'package:kothayhisab/presentation/sales/sales_page.dart';
import 'package:kothayhisab/presentation/shops/add_new_shop.dart';

import 'package:kothayhisab/presentation/shops/shop_screen.dart';
import 'package:kothayhisab/presentation/inventory/inventory_page.dart';
import 'package:kothayhisab/presentation/inventory/add_inventory_screen.dart';

// Define the routes for navigation
final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.homePage: (context) => const HomeScreen(),
  AppRoutes.splashPage: (context) => const SplashScreen(),
  AppRoutes.loginPage: (context) => const LoginScreen(),
  AppRoutes.registerPage: (context) => const RegisterScreen(),

  AppRoutes.profilePage: (context) => const ProfileScreen(),
  AppRoutes.editProfilePage: (context) => const EditProfileScreen(),
  AppRoutes.profileSettingsPage: (context) => const ProfileSettingsScreen(),
  AppRoutes.helpPage: (context) => const HelpScreen(),

  AppRoutes.addShopPage: (context) => const ShopCreationScreen(),

  '/shop-details': (context) => const ShopScreen(),

  '/shop-details/store/add_inventory': (context) => AddInventoryScreen(),
  '/shop-details/store/see_inventory': (context) => InventoryPage(),

  '/shop-details/store/add_sales': (context) => AddSalesScreen(),
  '/shop-details/store/see_sales': (context) => SalesPage(),
};
