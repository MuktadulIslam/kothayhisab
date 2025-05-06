// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/data/api/middleware/auth_middleware.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';
import 'package:kothayhisab/config/app_config.dart';
import 'package:kothayhisab/data/api/services/shops_service.dart';
import 'package:kothayhisab/data/models/shop_model.dart';
import 'package:kothayhisab/config/app_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  bool _isLoadingShops = false;
  String? _errorMessage;
  List<Shop> shops = [];
  final ShopsService _shopsService = ShopsService();

  @override
  void initState() {
    super.initState();
    // Check if user is authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthMiddleware.checkAuth(context);
      _loadShops(); // Load shops when screen initializes
    });
  }

  // Load shops data from API
  Future<void> _loadShops() async {
    setState(() {
      _isLoadingShops = true;
      _errorMessage = null;
    });

    try {
      final shopsList = await _shopsService.getShops();
      setState(() {
        shops = shopsList;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading shops: ${e.toString()}';
        print(_errorMessage);
      });
    } finally {
      setState(() {
        _isLoadingShops = false;
      });
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    final response = await AuthService.logout();

    setState(() {
      _isLoading = false;
    });

    if (response['success']) {
      // Navigate to login screen on successful logout
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.loginPage);
      }
    } else {
      setState(() {
        print(response['message']);
      });
    }
  }

  Future<void> _refreshShops() async {
    return _loadShops();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        // backgroundColor: Colors.white,
        title: Image.asset(
          'assets/images/home_logo.jpg',
          height: 50,
          fit: BoxFit.contain,
        ),
        automaticallyImplyLeading: false, // This removes the back button
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Color(0xFF00558D)),
            onPressed: _logout,
            tooltip: 'Logout',
            iconSize: 25,
          ),
        ],
      ),
      body: Column(
        children: [
          // Error message if any
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.red[100],
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          // Shop list using ListView.builder
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshShops,
              child:
                  _isLoadingShops
                      ? const Center(child: CircularProgressIndicator())
                      : shops.isEmpty
                      ? const Center(
                        child: Text(
                          'কোন দোকান যোগ করা হয়নি!',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 139, 133, 133),
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: shops.length,
                        padding: const EdgeInsets.only(top: 8),
                        itemBuilder: (context, index) {
                          final shop = shops[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/shop-details',
                                arguments: {'shop': shop},
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF2F8FF,
                                ), // Changed from Colors.white to #f2f8ff
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(
                                      255,
                                      43,
                                      43,
                                      43,
                                    ).withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 2,
                                ),
                                title: Text(
                                  shop.name,
                                  style: const TextStyle(
                                    color: Color(0xFF00558D),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: Colors.black54,
                                      ),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'ঠিকানাঃ ',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: shop.address,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00558D),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ),
          // Add New Shop button at the bottom that redirects to another page
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              height: 48,
              width: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF00558D),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.blue.shade300, width: 1),
              ),
              child: InkWell(
                onTap: () {
                  // Redirect to add shop page
                  Navigator.pushNamed(context, AppRoutes.addShopPage).then((_) {
                    // Refresh the shops list when returning from add shop page
                    _loadShops();
                  });
                },
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'দোকান যোগ করুন ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add,
                            color: Color(0xFF00558D),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(),
    );
  }
}
