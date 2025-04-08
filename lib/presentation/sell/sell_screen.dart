import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/bangla_language.dart';

class SellScreen extends StatelessWidget {
  const SellScreen({super.key}); // Added semicolon here

  @override
  Widget build(BuildContext context) {
    // Define grid items with their icons, names and routes
    final List<Map<String, dynamic>> _gridItems = [
      {
        'name': BanglaLanguage.addSellProducts,
        'icon': Icons.add_box_outlined,
        'route': '/',
        'color': Colors.blue,
      },
      {
        'name': BanglaLanguage.seeSellProducts,
        'icon': Icons.view_cozy_outlined,
        'route': '/',
        'color': Colors.orange,
      },
    ];

    void handleGridItemTap(int index) {
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text(
          BanglaLanguage.sell,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Color.fromARGB(255, 26, 30, 87),
          ),
        ),
      ),
      body: Column(
        children: [
          // Grid section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
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
                      onTap: () => handleGridItemTap(index),
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
