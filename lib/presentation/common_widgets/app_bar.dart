import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar(this.appbarTitle, {super.key});
  final String appbarTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0C5D8F),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white, // Making the back button white
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        appbarTitle,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
