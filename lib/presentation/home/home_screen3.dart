import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop List App',
      theme: ThemeData(
        primaryColor: const Color(0xFF00558D),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF00558D),
          secondary: const Color(0xFF00558D),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/shop-details': (context) => const ShopDetailsScreen(),
        '/profile': (context) => const ProfileScreen2(),
        '/add-shop':
            (context) => const AddShopScreen(), // New route for add shop page
      },
    );
  }
}

// Shop model class to store shop data
class Shop {
  final String id;
  final String name;
  final String location;

  Shop({required this.id, required this.name, required this.location});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sample shop data array
  List<Shop> shops = [
    // Shop(id: '1', name: 'Murad Store', location: 'Murad Nagar'),
    // Shop(id: '2', name: 'Central Market', location: 'Downtown Area'),
    // Shop(id: '3', name: 'Family Mart', location: 'Residential Zone'),
    // Shop(id: '4', name: 'Quick Shop', location: 'Highway Exit 12'),
    // Shop(id: '5', name: 'Grocery Plus', location: 'Main Street'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Shop List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF00558D),
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
      bottomNavigationBar: BottomAppBar(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// New Add Shop Screen
class AddShopScreen extends StatefulWidget {
  const AddShopScreen({super.key});

  @override
  State<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends State<AddShopScreen> {
  // Text controllers for the add shop form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Shop',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00558D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Shop Name',
                hintText: 'Enter shop name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Enter shop location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _locationController.text.isNotEmpty) {
                  // Create new shop and pass it back to previous screen
                  final newShop = Shop(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: _nameController.text,
                    location: _locationController.text,
                  );
                  Navigator.pop(context, newShop);
                } else {
                  // Show error message if fields are empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00558D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shop Details Screen (that arrow button navigates to)
class ShopDetailsScreen extends StatelessWidget {
  const ShopDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Receive the shop data passed from the HomeScreen
    final shop = ModalRoute.of(context)!.settings.arguments as Shop;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shop Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00558D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${shop.name} Details',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text('Address: ${shop.location}, Main Street'),
            const SizedBox(height: 8),
            const Text('Phone: +123 456 7890'),
            const SizedBox(height: 8),
            const Text('Hours: 9:00 AM - 9:00 PM'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00558D),
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile Screen (that three dot icon navigates to)
class ProfileScreen2 extends StatelessWidget {
  const ProfileScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF00558D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              size: 100,
              color: Color(0xFF00558D),
            ),
            const SizedBox(height: 20),
            const Text(
              'User Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Name: John Doe'),
            const SizedBox(height: 8),
            const Text('Email: john.doe@example.com'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00558D),
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
