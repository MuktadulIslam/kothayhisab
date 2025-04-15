import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('2-Column Grid Example')),
      body: Padding(
        padding: const EdgeInsets.all(15),

        // Option 1: Using GridView.count
        child: GridView.count(
          crossAxisCount: 2, // Number of columns
          crossAxisSpacing: 20, // Horizontal space between items
          mainAxisSpacing: 15, // Vertical space between items
          childAspectRatio: 1.6,
          children: List.generate(10, (index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.blue[100 * ((index % 5) + 1)],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.blue[200 * ((index % 5) + 1)],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [Text('Item ${index + 1}')],
                      ),
                    ),
                    // Icon Box
                    Expanded(
                      // Use Expanded instead of fixed-height Container
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blue[300 * ((index % 5) + 1)],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.store,
                              color: Color(0xFF0C5D8F),
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
