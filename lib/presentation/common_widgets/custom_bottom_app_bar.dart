import 'package:flutter/material.dart';
import 'package:kothayhisab/core/constants/app_routes.dart';

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
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRoutes.homePage);
                },
                child: const Center(child: Icon(Icons.home, size: 28)),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.profilePage);
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
