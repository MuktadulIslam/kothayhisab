// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/data/api/middleware/auth_middleware.dart';
import 'package:kothayhisab/core/constants/bangla_language.dart';
import 'package:kothayhisab/presentation/common_widgets/custom_bottom_app_bar.dart';

class Shop {
  final String id;
  final String name;
  final String location;

  Shop({required this.id, required this.name, required this.location});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if user is authenticated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AuthMiddleware.checkAuth(context);
    });
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    final response = await _authService.logout();

    setState(() {
      _isLoading = false;
    });

    if (response['success']) {
      // Navigate to login screen on successful logout
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } else {
      setState(() {
        print(response['message']);
      });
    }
  }

  List<Shop> shops = [
    Shop(id: '1', name: 'Murad Store', location: 'Murad Nagar'),
    Shop(id: '2', name: 'Central Market', location: 'Downtown Area'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 38, 93),
        title: const Text(
          BanglaLanguage.appName,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false, // This removes the back button
        actions: [
          _isLoading
              ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
              : IconButton(
                icon: const Icon(Icons.exit_to_app, color: Colors.white),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
        ],
      ),
      body: Column(
        children: [
          // Shop list using ListView.builder
          Expanded(
            child:
                shops.isEmpty
                    ? const Center(
                      child: Text(
                        'No shops available',
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
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            title: Text(
                              shop.name,
                              style: const TextStyle(
                                color: Color(0xFF00558D),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Location: ${shop.location}',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00558D),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/shop-details',
                                    arguments: shop,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
          // Add New Shop button at the bottom that redirects to another page
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Container(
              height: 48,
              width: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF00558D),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.blue.shade300, width: 1),
              ),
              child: InkWell(
                onTap: () {
                  // Redirect to add shop page instead of showing dialog
                  Navigator.pushNamed(context, '/add-shop').then((value) {
                    // Refresh the list if a new shop was added
                    if (value != null && value is Shop) {
                      setState(() {
                        shops.add(value);
                      });
                    }
                  });
                },
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add New Shop',
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
