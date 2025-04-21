import 'package:flutter/material.dart';
import 'package:kothayhisab/presentation/common_widgets/app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/presentation/common_widgets/store_card.dart';

class MenuItem {
  final String title;
  final String routePath;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  MenuItem({
    required this.title,
    required this.routePath,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}

class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List of menu items with title, route path, and icon
    final List<MenuItem> menuItems = [
      MenuItem(
        title: 'মজুদ করুন', // "Products" in Bengali
        routePath: '/shop-details/store/add_inventory',
        icon: Icons.add_business_sharp,
        backgroundColor: const Color.fromARGB(
          255,
          186,
          195,
          245,
        ).withOpacity(0.9),
        iconColor: const Color(0xFF0C5D8F),
      ),
      MenuItem(
        title: 'মজুদ দেখুন', // "Sales" in Bengali
        routePath: '/shop-details/store/see_inventory',
        icon: Icons.open_with,
        backgroundColor: const Color(0xFFE6F9E6),
        iconColor: Colors.green,
      ),
      MenuItem(
        title: 'বিক্রয় করুন', // "Products" in Bengali
        routePath: '/shop-details/store/add_sales',
        icon: Icons.add_business_sharp,
        backgroundColor: const Color.fromARGB(
          255,
          186,
          195,
          245,
        ).withOpacity(0.9),
        iconColor: const Color(0xFF0C5D8F),
      ),
      MenuItem(
        title: 'বিক্রয় দেখুন', // "Sales" in Bengali
        routePath: '/shop-details/store/see_sales',
        icon: Icons.open_with,
        backgroundColor: const Color(0xFFE6F9E6),
        iconColor: Colors.green,
      ),

      MenuItem(
        title: 'বাকির হিসাব', // "Accounts" in Bengali
        routePath: '/shop-details/store/see_inventory',
        icon: Icons.account_balance_wallet_outlined,
        backgroundColor: const Color.fromARGB(255, 217, 219, 227),
        iconColor: Colors.indigo,
      ),
      MenuItem(
        title: 'রিপোর্ট', // "Reports" in Bengali
        routePath: '/shop-details/reports',
        icon: Icons.bar_chart,
        backgroundColor: const Color(0xFFE1F5FE),
        iconColor: Colors.blue,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar('মুরাদ ষ্টোর'), // "Root Store" in Bengali
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Card
            StoreCard(),
            const SizedBox(height: 24),

            // Grid Menu
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two columns
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 2, // Adjust as needed for your design
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return MenuItemCard(menuItem: menuItems[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;

  const MenuItemCard({Key? key, required this.menuItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, menuItem.routePath);
      },
      child: Container(
        decoration: BoxDecoration(
          color: menuItem.backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(menuItem.icon, color: menuItem.iconColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              menuItem.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
