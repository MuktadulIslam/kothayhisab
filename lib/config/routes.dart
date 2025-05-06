// lib/config/routes.dart
import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';
import 'package:kothayhisab/data/models/sales_model.dart';
import 'package:kothayhisab/data/models/shop_model.dart';
import 'package:kothayhisab/presentation/customer_accounts/add_customer_account_screen.dart';
import 'package:kothayhisab/presentation/customer_accounts/customer_account_details_screen.dart';
import 'package:kothayhisab/presentation/customer_accounts/customer_accounts_screen.dart';

import 'package:kothayhisab/presentation/home/home_screen.dart';
import 'package:kothayhisab/presentation/home/splash_screen.dart';
import 'package:kothayhisab/presentation/auth/login/login_screen.dart';
import 'package:kothayhisab/presentation/auth/register/register_screen.dart';
// import 'package:kothayhisab/presentation/payments/due_payment_screen.dart';
import 'package:kothayhisab/presentation/profile/edit_profile_screen.dart';
import 'package:kothayhisab/presentation/profile/help_screen.dart';
import 'package:kothayhisab/presentation/profile/profile_screen.dart';
import 'package:kothayhisab/presentation/profile/settings_screen.dart';
import 'package:kothayhisab/presentation/sales/add_sales_screen.dart';
import 'package:kothayhisab/presentation/sales/due_sales_screen.dart';
import 'package:kothayhisab/presentation/sales/sales_page.dart';
import 'package:kothayhisab/presentation/shops/add_employee_page.dart';
import 'package:kothayhisab/presentation/shops/add_new_shop.dart';
import 'package:kothayhisab/presentation/shops/employee_list_page.dart';

import 'package:kothayhisab/presentation/shops/shop_screen.dart';
import 'package:kothayhisab/presentation/inventory/inventory_page.dart';
import 'package:kothayhisab/presentation/inventory/add_inventory_screen.dart';
import 'package:kothayhisab/presentation/shops/update_shop.dart';

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
  '/shop-details/update-shop': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final shop =
        args?['shop'] as Shop? ?? Shop(name: '', address: '', gpsLocation: '');
    return ShopUpdateScreen(shop: shop);
  },

  '/shop-details/see-employees': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final shopId = args?['shopId'] as String? ?? '0';
    return EmployeeListPage(shopId: shopId);
  },

  '/shop-details/add-employees': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final shopId = args?['shopId'] as String? ?? '0';

    return AddEmployeePage(
      shopId: shopId,
      // Use a no-op callback to avoid crashes if onEmployeeAdded is invoked
      onEmployeeAdded: () {
        // Navigate back to the employees list page safely
        // Rebuild the previous page by using named routes
        Navigator.pushReplacementNamed(
          context,
          '/shop-details/see-employees',
          arguments: {'shopId': shopId},
        );
      },
    );
  },

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
  // '/shop-details/add_sales': (context) {
  //   final args =
  //       ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
  //   final shopId = args?['shopId'] as String? ?? '';
  //   return AddSalesScreen(shopId: shopId);
  // },
  '/shop-details/see_sales': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final shopId = args?['shopId'] as String? ?? '';
    return SalesPage(shopId: shopId);
  },

  '/shop-details/see_dues': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final shopId = args?['shopId'] as String? ?? '';
    return DuePage(shopId: shopId);
  },

  '/shop-details/add-customer-accounts': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final shopId = args?['shopId'] as String? ?? '';
    return AddCustomerAccountsScreen(shopId: shopId);
  },
  '/shop-details/see-customer-accounts': (context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final shopId = args?['shopId'] as String? ?? '';
    return CustomerAccountsScreen(shopId: shopId);
  },

  // '/shop-details/see-customer-accounts/details': (context) {
  //   final args =
  //       ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
  //   final dueAccount =
  //       args?['customer'] as Customer? ??
  //       Customer(
  //         id: '',
  //         name: '',
  //         address: '',
  //         mobileNumber: '',
  //         createdAt: DateTime.now(),
  //         photoPath: null,
  //       );

  //   return DueAccountsDetailsScreen(customer: dueAccount);
  // },

  // '/shop-details/make-due-payment': (context) {
  //   final args =
  //       ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
  //   final shopId = args?['shopId'] as String? ?? '';
  //   final dueAccount =
  //       args?['customer'] as Customer? ??
  //       Customer(
  //         id: '',
  //         name: '',
  //         address: '',
  //         mobileNumber: '',
  //         createdAt: DateTime.now(),
  //         photoPath: null,
  //       );

  //   return DuePaymentScreen(customer: dueAccount, shopId: shopId);
  // },
};
