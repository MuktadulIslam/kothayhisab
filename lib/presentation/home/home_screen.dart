// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:kothayhisab/data/api/services/auth_service.dart';
import 'package:kothayhisab/data/api/middleware/auth_middleware.dart';
import 'package:kothayhisab/core/constants/bangla_language.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Define grid items with their icons, names and routes
  final List<Map<String, dynamic>> _gridItems = [
    {
      'name': BanglaLanguage.store,
      'icon': Icons.add_business_rounded,
      'route': '/store',
      'color': Colors.blue,
    },
    {
      'name': BanglaLanguage.sell,
      'icon': Icons.store_rounded,
      'route': '/sell',
      'color': Colors.green,
    },
    {
      'name': BanglaLanguage.monthlyReport,
      'icon': Icons.bar_chart,
      'route': '/monthlyReport',
      'color': Colors.orange,
    },
    {
      'name': BanglaLanguage.myshop,
      'icon': Icons.holiday_village_sharp,
      'route': '/shops',
      'color': Colors.pink,
    },
    {
      'name': 'Settings',
      'icon': Icons.settings,
      'route': '/settings',
      'color': Colors.purple,
    },
    {
      'name': 'Profile',
      'icon': Icons.person,
      'route': '/profile',
      'color': Colors.indigo,
    },
    {'name': 'Help', 'icon': Icons.help, 'route': '/help', 'color': Colors.red},
  ];

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

  void _handleGridItemTap(int index) {
    final route = _gridItems[index]['route'];

    // Navigate to the corresponding route if it exists
    if (route != null) {
      Navigator.of(context).pushNamed(route);
    } else {
      // Fallback for items without routes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feature coming soon: ${_gridItems[index]['name']}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          BanglaLanguage.appName,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Color.fromARGB(255, 26, 30, 87),
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
                icon: const Icon(Icons.exit_to_app),
                onPressed: _logout,
                tooltip: 'Logout',
              ),
        ],
      ),
      body: Column(
        children: [
          // Grid section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Three columns
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: _gridItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: InkWell(
                      onTap: () => _handleGridItemTap(index),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon/Image
                          Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: _gridItems[index]['color'].withOpacity(
                                0.2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _gridItems[index]['icon'],
                              size: 36,
                              color: _gridItems[index]['color'],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Name
                          Text(
                            _gridItems[index]['name'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
