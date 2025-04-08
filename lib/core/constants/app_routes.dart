class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Route path constants
  static const String homePage = '/';
  static const String loginPage = '/login';
  static const String registerPage = '/register';
  static const String profilePage = '/profile';
  static const String productList = '/products';
  static const String productDetail = '/products/:id';

  // Helper method to get dynamic routes with parameters
  static String getProductDetailRoute(String productId) {
    return productDetail.replaceAll(':id', productId);
  }
}
