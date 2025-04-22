// lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';
import 'package:kothayhisab/data/models/shop_model.dart';

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

  // Shop details with shopId as parameter
  '/shop-details': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final shop =
        args?['shop'] as Shop? ?? Shop(name: '', address: '', gpsLocation: '');
    return ShopScreen(shop: shop);
  },

  // Inventory routes with shopId
  '/shop-details/add-inventory': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final shopId = args?['shopId'] as String? ?? '';
    return AddInventoryScreen(shopId: shopId);
  },

  '/shop-details/see-inventory': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final shopId = args?['shopId'] as String? ?? '';
    return InventoryPage(shopId: shopId);
  },

  // Sales routes with shopId
  '/shop-details/add_sales': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final shopId = args?['shopId'] as String? ?? '';
    return AddSalesScreen(shopId: shopId);
  },

  '/shop-details/see_sales': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final shopId = args?['shopId'] as String? ?? '';
    return SalesPage(shopId: shopId);
  },
};
