import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  const CustomBottomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 56, // Standard height for bottom navigation
      color: const Color.fromARGB(255, 215, 231, 246),
      child: SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Center(child: Icon(Icons.home, size: 28)),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: const Center(
                  child: Icon(Icons.table_rows_rounded, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
