import 'package:flutter/material.dart';

class CustomGridView extends StatelessWidget {
  final List<Map<String, dynamic>> gridItems;

  const CustomGridView({super.key, required this.gridItems});

  void _handleGridItemTap(BuildContext context, int index) {
    final route = gridItems[index]['route'];

    // Navigate to the corresponding route if it exists
    if (route != null && route.isNotEmpty) {
      Navigator.of(context).pushNamed(route);
    } else {
      // Fallback for items without routes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Feature coming soon: ${gridItems[index]['name']}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Three columns
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 1.0,
          ),
          itemCount: gridItems.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: InkWell(
                onTap: () => _handleGridItemTap(context, index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon/Image
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: gridItems[index]['color'].withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        gridItems[index]['icon'],
                        size: 36,
                        color: gridItems[index]['color'],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Name
                    Text(
                      gridItems[index]['name'],
                      style: const TextStyle(
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
    );
  }
}
