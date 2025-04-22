// lib/core/constants/app_routes.dart

final List<String> nonAuthRoutes = [
  AppRoutes.loginPage,
  AppRoutes.registerPage,
  AppRoutes.forgotPasswordPage,
  AppRoutes.splashPage,
];

class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route path constants
  static const String homePage = '/';
  static const String loginPage = '/login';
  static const String registerPage = '/register';
  static const String splashPage = '/splash';

  static const String profilePage = '/profile';
  static const String profileSettingsPage = '/settings';
  static const String editProfilePage = '/edit-profile';
  static const String helpPage = '/help';
  static const String changePasswordPage = '/change-password';
  static const String forgotPasswordPage = '/forgot-password';

  static const String shopDetailsPage = '/shop-details/:id';
  static const String addShopPage = '/add-shop';

  static const String addEmployeePage = '/shop-details/:id/add_employee';
  static const String deleteEmployeePage = '/shop-details/:id/see_employee';

  static const String addInventory = '/shop-details/:id/add_inventory';
  static const String seeInventory = '/shop-details/:id/see_inventory';

  static const String addSales = '/shop-details/:id/add_sales';
  static const String seeSales = '/shop-details/:id/see_sales';

  static const String seeDueAmount = '/shop-details/:id/see_due_amount';
}
